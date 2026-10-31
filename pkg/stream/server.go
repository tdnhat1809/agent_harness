package stream

import (
	"encoding/binary"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/websocket"

	"hcbox/pkg/device"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
	ReadBufferSize:  1024 * 128,
	WriteBufferSize: 1024 * 128,
}

// Server provides the WebSocket video streaming bridge from scrcpy to web clients
type Server struct {
	deviceMgr *device.DeviceManager
	addr      string
	server    *http.Server
}

// NewServer creates a new stream server
func NewServer(deviceMgr *device.DeviceManager, addr string) *Server {
	if addr == "" {
		addr = ":18848"
	}
	return &Server{
		deviceMgr: deviceMgr,
		addr:      addr,
	}
}

// Handler returns the http.Handler for the stream server
func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/scrcpy", s.HandleScrcpyStream)
	return mux
}

// Start begins listening on the stream port
func (s *Server) Start() error {
	s.server = &http.Server{
		Addr:    s.addr,
		Handler: s.Handler(),
	}
	return s.server.ListenAndServe()
}

// Close stops the streaming server
func (s *Server) Close() error {
	if s.server != nil {
		return s.server.Close()
	}
	return nil
}

// BuildInitialPacket constructs the 126-byte header expected by the frontend's StreamConnectionManager
func BuildInitialPacket(deviceName string, width, height int) []byte {
	buf := make([]byte, 126)
	// 1. Magic bytes (14 bytes): "scrcpy_initial"
	copy(buf[0:14], "scrcpy_initial")

	// 2. Device Name (64 bytes null-padded)
	nameBytes := []byte(deviceName)
	if len(nameBytes) > 64 {
		nameBytes = nameBytes[:64]
	}
	copy(buf[14:78], nameBytes)

	// 3. Display count (int32 BE) = 1
	binary.BigEndian.PutUint32(buf[78:82], 1)

	// 4. Display 0 info (36 bytes):
	// displayId = 0
	binary.BigEndian.PutUint32(buf[82:86], 0)
	// width
	binary.BigEndian.PutUint32(buf[86:90], uint32(width))
	// height
	binary.BigEndian.PutUint32(buf[90:94], uint32(height))
	// rotation = 0
	binary.BigEndian.PutUint32(buf[94:98], 0)
	// layerStack = 0
	binary.BigEndian.PutUint32(buf[98:102], 0)
	// flags = 0
	binary.BigEndian.PutUint32(buf[102:106], 0)
	// connectionCount = 0
	binary.BigEndian.PutUint32(buf[106:110], 0)
	// videoSettings len = 0
	binary.BigEndian.PutUint32(buf[110:114], 0)
	// screenInfo len = 0
	binary.BigEndian.PutUint32(buf[114:118], 0)

	// 5. Client stats: clientCount = 0, clientId = 1
	binary.BigEndian.PutUint32(buf[118:122], 0)
	binary.BigEndian.PutUint32(buf[122:126], 1)

	return buf
}

// NALUSplitter buffers fragmented TCP chunks and emits complete Annex-B NAL units
type NALUSplitter struct {
	buffer []byte
}

// NewNALUSplitter creates a new NALUSplitter
func NewNALUSplitter() *NALUSplitter {
	return &NALUSplitter{
		buffer: make([]byte, 0, 1024*128),
	}
}

// Push appends data and extracts all fully received Annex-B NAL units
func (s *NALUSplitter) Push(chunk []byte) [][]byte {
	s.buffer = append(s.buffer, chunk...)
	var nalus [][]byte

	for {
		startIdx := findStartCode(s.buffer)
		if startIdx == -1 {
			if len(s.buffer) > 4 {
				s.buffer = s.buffer[len(s.buffer)-4:]
			}
			break
		}

		if startIdx > 0 {
			s.buffer = s.buffer[startIdx:]
		}

		startCodeLen := 4
		if len(s.buffer) >= 3 && s.buffer[0] == 0 && s.buffer[1] == 0 && s.buffer[2] == 1 {
			startCodeLen = 3
		}
		if len(s.buffer) <= startCodeLen {
			break
		}

		nextIdx := findStartCode(s.buffer[startCodeLen:])
		if nextIdx == -1 {
			break
		}

		endIdx := startCodeLen + nextIdx
		nalu := make([]byte, endIdx)
		copy(nalu, s.buffer[:endIdx])
		nalus = append(nalus, nalu)

		s.buffer = s.buffer[endIdx:]
	}

	return nalus
}

// Flush returns any remaining complete NAL unit in the buffer upon stream close
func (s *NALUSplitter) Flush() [][]byte {
	var nalus [][]byte
	startIdx := findStartCode(s.buffer)
	if startIdx != -1 {
		data := s.buffer[startIdx:]
		if len(data) >= 4 {
			nalu := make([]byte, len(data))
			copy(nalu, data)
			nalus = append(nalus, nalu)
		}
	}
	s.buffer = nil
	return nalus
}

func findStartCode(data []byte) int {
	for i := 0; i <= len(data)-3; i++ {
		if data[i] == 0 && data[i+1] == 0 {
			if data[i+2] == 1 {
				return i
			}
			if i+3 < len(data) && data[i+2] == 0 && data[i+3] == 1 {
				return i
			}
		}
	}
	return -1
}

// HandleScrcpyStream connects to the device scrcpy video socket and pipes frames to WebSocket
func (s *Server) HandleScrcpyStream(w http.ResponseWriter, r *http.Request) {
	udid := r.URL.Query().Get("udid")
	portStr := r.URL.Query().Get("port")
	port, _ := strconv.Atoi(portStr)

	wsConn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Stream websocket upgrade failed:", err)
		return
	}
	defer wsConn.Close()

	var devWidth, devHeight int = 1072, 2208
	var devName string = "Android Device"

	if s.deviceMgr != nil {
		if dev, found := s.deviceMgr.GetDevice(udid); found && dev != nil {
			if port <= 0 && dev.H264LocalPort > 0 {
				port = dev.H264LocalPort
			}
			if dev.Width > 0 {
				devWidth = dev.Width - (dev.Width % 16)
			}
			if dev.Height > 0 {
				devHeight = dev.Height - (dev.Height % 16)
			}
			if dev.Name != "" {
				devName = dev.Name
			}
		}
	}

	if port <= 0 {
		port = 27183
	}

	scrcpyAddr := fmt.Sprintf("127.0.0.1:%d", port)

	// Ensure scrcpy-server is running on device
	if s.deviceMgr != nil && udid != "" {
		if !s.deviceMgr.IsScrcpyRunning(udid) {
			_ = s.deviceMgr.StartScrcpy(udid)
		} else {
			_ = s.deviceMgr.EnsureForward(udid, port)
		}
	}

	// Dial the local forward port created by adb forward with retry
	var videoConn net.Conn
	for attempt := 0; attempt < 3; attempt++ {
		c, err := net.DialTimeout("tcp", scrcpyAddr, 2*time.Second)
		if err == nil {
			videoConn = c
			break
		}
		if s.deviceMgr != nil && udid != "" {
			_ = s.deviceMgr.StartScrcpy(udid)
		}
		time.Sleep(400 * time.Millisecond)
	}
	if videoConn == nil {
		log.Printf("[%s] failed to connect video socket at %s", udid, scrcpyAddr)
		return
	}
	defer videoConn.Close()

	// Dial Socket 2 (Control socket required by scrcpy before video begins)
	ctrlConn, err := net.DialTimeout("tcp", scrcpyAddr, 2*time.Second)
	if err == nil {
		defer ctrlConn.Close()
		if s.deviceMgr != nil {
			s.deviceMgr.SetControlSocket(udid, ctrlConn)
		}
	} else {
		log.Printf("[%s] warning: control socket connect failed: %v", udid, err)
	}

	// 1. Consume scrcpy dummy byte (0x00)
	dummy := make([]byte, 1)
	if _, err := io.ReadFull(videoConn, dummy); err != nil {
		log.Printf("[%s] failed to read scrcpy dummy byte: %v", udid, err)
		return
	}

	// 2. Consume scrcpy device name (64 bytes)
	nameBuf := make([]byte, 64)
	if _, err := io.ReadFull(videoConn, nameBuf); err != nil {
		log.Printf("[%s] failed to read scrcpy device name: %v", udid, err)
		return
	}
	parsedName := strings.TrimRight(string(nameBuf), "\x00")
	if parsedName != "" {
		devName = parsedName
	}

	// 3. Send scrcpy_initial packet expected by StreamConnectionManager
	initialPacket := BuildInitialPacket(devName, devWidth, devHeight)
	if err := wsConn.WriteMessage(websocket.BinaryMessage, initialPacket); err != nil {
		log.Printf("[%s] failed to send initial packet: %v", udid, err)
		return
	}

	// Bidirectional pipe
	done := make(chan struct{})

	// TCP Video -> NALUSplitter (framing complete Annex-B NAL units) -> WebSocket
	go func() {
		defer close(done)
		splitter := NewNALUSplitter()
		buffer := make([]byte, 1024*64)
		for {
			n, err := videoConn.Read(buffer)
			if err != nil {
				for _, nalu := range splitter.Flush() {
					_ = wsConn.WriteMessage(websocket.BinaryMessage, nalu)
				}
				if err != io.EOF {
					log.Printf("[%s] stream read error: %v", udid, err)
				}
				break
			}
			if n > 0 {
				nalus := splitter.Push(buffer[:n])
				for _, nalu := range nalus {
					err = wsConn.WriteMessage(websocket.BinaryMessage, nalu)
					if err != nil {
						return
					}
				}
			}
		}
	}()

	// WebSocket Client -> TCP Control
	go func() {
		for {
			_, msg, err := wsConn.ReadMessage()
			if err != nil {
				break
			}
			if len(msg) > 0 && ctrlConn != nil {
				_, _ = ctrlConn.Write(msg)
			}
		}
	}()

	<-done
}

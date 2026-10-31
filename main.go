package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
	"time"

	"hcbox/pkg/api"
	"hcbox/pkg/device"
	"hcbox/pkg/stream"
	"hcbox/pkg/ws"

	"github.com/gin-gonic/gin"
)

func main() {
	apiPort := flag.String("api-port", ":20080", "REST API listening address")
	wsPort := flag.String("ws-port", ":28848", "WebSocket Control Hub listening address")
	streamPort := flag.String("stream-port", ":18848", "Video Stream server listening address")
	adbPath := flag.String("adb", "", "Path to adb executable")
	guiMode := flag.Bool("gui", false, "Launch desktop application window automatically")
	flag.Parse()

	log.Println("==================================================")
	log.Println("  HC BOX Reconstructed Backend Core (Go Native)   ")
	log.Println("  Unlimited Phone Farm Controller & Scrcpy Bridge ")
	log.Println("==================================================")

	// 1. Initialize Hardware Bridge & Device Manager
	adbBridge := device.NewADBBridge(*adbPath)
	deviceMgr := device.NewDeviceManager(adbBridge)

	// Scan initial physical devices
	_, _ = deviceMgr.ScanDevices()

	// 2. Initialize Servers
	apiServer := api.NewServer(deviceMgr, *apiPort)
	wsHub := ws.NewHub(deviceMgr, *wsPort)
	streamServer := stream.NewServer(deviceMgr, *streamPort)

	// Mount WebSocket directly on API server as well for single-port / fallback access
	apiServer.Router().GET("/ws", func(c *gin.Context) {
		wsHub.HandleWebSocket(c.Writer, c.Request)
	})

	// 3. Start Servers in background goroutines
	errChan := make(chan error, 3)

	go func() {
		log.Printf("[+] Starting REST API Server at http://127.0.0.1%s", *apiPort)
		if err := apiServer.Start(); err != nil {
			errChan <- fmt.Errorf("API Server error: %v", err)
		}
	}()

	go func() {
		log.Printf("[+] Starting WebSocket Control Hub at ws://127.0.0.1%s/ws", *wsPort)
		if err := wsHub.Start(); err != nil {
			errChan <- fmt.Errorf("WebSocket Hub error: %v", err)
		}
	}()

	go func() {
		log.Printf("[+] Starting Video Stream Server at ws://127.0.0.1%s/scrcpy", *streamPort)
		if err := streamServer.Start(); err != nil {
			errChan <- fmt.Errorf("Stream Server error: %v", err)
		}
	}()

	// Periodic ADB device scanner
	go func() {
		for {
			if devices, err := deviceMgr.ScanDevices(); err == nil && len(devices) > 0 {
				wsHub.BroadcastDevices()
			}
			time.Sleep(3 * time.Second)
		}
	}()

	if *guiMode {
		go func() {
			time.Sleep(800 * time.Millisecond)
			edgePath := `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`
			appUrl := fmt.Sprintf("http://127.0.0.1%s/#/console", *apiPort)
			if _, err := os.Stat(edgePath); err == nil {
				_ = exec.Command(edgePath, fmt.Sprintf("--app=%s", appUrl), "--window-size=1440,900").Start()
			} else {
				_ = exec.Command("cmd", "/c", "start", appUrl).Start()
			}
		}()
	}

	// 4. Handle OS signals for graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	select {
	case sig := <-sigChan:
		log.Printf("[*] Received shutdown signal: %v. Cleaning up...", sig)
	case err := <-errChan:
		log.Fatalf("[-] Critical server error: %v", err)
	}

	_ = wsHub.Close()
	_ = streamServer.Close()
	log.Println("[+] HC BOX Backend Core shutdown cleanly.")
}

package device

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// ADBBridge handles communication with Android Debug Bridge
type ADBBridge struct {
	adbPath string
}

// NewADBBridge creates an instance of ADBBridge, locating adb.exe
func NewADBBridge(customPath string) *ADBBridge {
	path := customPath
	if path == "" {
		candidates := []string{
			"C:\\Program Files\\HC BOX\\resources\\adb\\adb.exe",
			filepath.Join("resources", "adb", "adb.exe"),
		}
		for _, cand := range candidates {
			if _, err := os.Stat(cand); err == nil {
				path = cand
				break
			}
		}
		if path == "" {
			if p, err := exec.LookPath("adb"); err == nil {
				path = p
			} else {
				path = "adb"
			}
		}
	}
	return &ADBBridge{adbPath: path}
}

// Run executes an adb command with the given arguments
func (b *ADBBridge) Run(args ...string) (string, error) {
	cmd := exec.Command(b.adbPath, args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		return "", fmt.Errorf("adb error: %v, stderr: %s", err, stderr.String())
	}
	return stdout.String(), nil
}

// ListDevices returns all connected ADB devices
func (b *ADBBridge) ListDevices() ([]string, error) {
	out, err := b.Run("devices")
	if err != nil {
		return nil, err
	}

	lines := strings.Split(out, "\n")
	var devices []string
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "List of devices") {
			continue
		}
		parts := strings.Fields(line)
		if len(parts) >= 2 && parts[1] == "device" {
			devices = append(devices, parts[0])
		}
	}
	return devices, nil
}

// ForwardPort creates a forward socket from local TCP port to device abstract socket
func (b *ADBBridge) ForwardPort(serial string, localPort int, remoteSocket string) error {
	_, err := b.Run("-s", serial, "forward", fmt.Sprintf("tcp:%d", localPort), remoteSocket)
	return err
}

// RemoveForward removes a port forward
func (b *ADBBridge) RemoveForward(serial string, localPort int) error {
	_, err := b.Run("-s", serial, "forward", "--remove", fmt.Sprintf("tcp:%d", localPort))
	return err
}

// PushFile pushes a file to the device
func (b *ADBBridge) PushFile(serial string, localPath, remotePath string) error {
	_, err := b.Run("-s", serial, "push", localPath, remotePath)
	return err
}

// Shell executes a shell command on the target device
func (b *ADBBridge) Shell(serial string, cmd string) (string, error) {
	return b.Run("-s", serial, "shell", cmd)
}

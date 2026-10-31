package api

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"

	"hcbox/pkg/device"
	"hcbox/pkg/models"
	"hcbox/pkg/workflow"
)

// Server encapsulates the Gin REST API engine
type Server struct {
	router    *gin.Engine
	deviceMgr *device.DeviceManager
	wfEngine  *workflow.Engine
	addr      string
	logMu     sync.RWMutex
	logs      []string
}

// NewServer creates and configures the REST API server on port 20080
func NewServer(deviceMgr *device.DeviceManager, addr string) *Server {
	if addr == "" {
		addr = ":20080"
	}

	gin.SetMode(gin.ReleaseMode)
	router := gin.New()
	router.Use(gin.Recovery())

	// CORS Middleware
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With, Token, AccessToken")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	s := &Server{
		router:    router,
		deviceMgr: deviceMgr,
		wfEngine:  workflow.NewEngine(deviceMgr),
		addr:      addr,
		logs:      make([]string, 0),
	}
	s.registerRoutes()
	return s
}

// registerRoutes configures all API routes
func (s *Server) registerRoutes() {
	// 1. Auth endpoints
	s.router.GET("/api/auth/version-check", s.handleVersionCheck)
	s.router.POST("/api/auth/login", s.handleLogin)
	s.router.POST("/api/auth/register", s.handleRegister)
	s.router.POST("/api/auth/reset-password", s.handleResetPassword)
	s.router.POST("/api/auth/send-verification-code", s.handleSendVerificationCode)

	// 2. User endpoints
	s.router.GET("/api/user/info", s.handleUserInfo)
	s.router.GET("/api/user/list", s.handleUserList)
	s.router.POST("/api/user/logout", s.handleUserLogout)

	// 3. System & Roles
	s.router.GET("/api/v3/system/menus/simple", s.handleMenusSimple)
	s.router.GET("/api/role/list", s.handleRoleList)

	// 4. Device endpoints
	s.router.GET("/device/list", s.handleDeviceList)
	s.router.GET("/api/device/app-icon", s.handleAppIcon)

	// 5. Workflow automation endpoints
	s.router.GET("/api/workflow/templates", s.handleWorkflowTemplates)
	s.router.GET("/api/workflow/status", s.handleWorkflowStatus)
	s.router.POST("/api/workflow/run", s.handleWorkflowRun)
	s.router.POST("/api/workflow/stop", s.handleWorkflowStop)
	s.router.GET("/api/workflow/logs", s.handleWorkflowLogs)
	s.router.GET("/workflow-builder", s.handleWorkflowBuilder)

	// 6. Static UI (Vue 3 / Element Plus SPA)
	uiCandidates := []string{
		"D:/python/bypass_hcbox/extracted_source",
		"extracted_source",
	}
	var uiDir string
	for _, c := range uiCandidates {
		if _, err := os.Stat(c); err == nil {
			uiDir = c
			break
		}
	}

	if uiDir != "" {
		s.router.Static("/assets", uiDir+"/assets")
		s.router.StaticFile("/favicon.ico", uiDir+"/favicon.ico")
		s.router.GET("/", func(c *gin.Context) {
			c.File(uiDir + "/index.html")
		})

		// Return 404 for Wails desktop runtime when accessed via regular browser
		s.router.Any("/wails/*filepath", func(c *gin.Context) {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "msg": "wails desktop bridge not attached"})
		})

		s.router.NoRoute(func(c *gin.Context) {
			p := c.Request.URL.Path
			// Return empty CSS for missing CSS chunks to satisfy Vite preloader
			if strings.HasSuffix(p, ".css") {
				c.Data(http.StatusOK, "text/css; charset=utf-8", []byte("/* empty css chunk */"))
				return
			}
			// Never return HTML for missing scripts, styles, images or wails RPCs
			if strings.Contains(p, ".") || strings.HasPrefix(p, "/wails") {
				c.JSON(http.StatusNotFound, gin.H{"code": 404, "msg": "not found"})
				return
			}
			if !strings.HasPrefix(p, "/api") && !strings.HasPrefix(p, "/ws") && !strings.HasPrefix(p, "/device") {
				c.File(uiDir + "/index.html")
				return
			}
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "msg": "not found"})
		})
	}
}

func (s *Server) handleVersionCheck(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: models.VersionInfo{
			Checked:        true,
			CurrentVersion: "1.0.9",
			ForceUpdate:    false,
			Message:        "Phiên bản hiện tại đã là mới nhất",
			NewVersion:     "1.0.9",
			Reason:         "latest",
			UpdateType:     "none",
			UpdateUrl:      "",
		},
	})
}

func (s *Server) handleLogin(c *gin.Context) {
	token := "hcbox_master_token_pro_unlimited"
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: gin.H{
			"token":       token,
			"accessToken": token,
			"userInfo": gin.H{
				"userId":         1,
				"userName":       "admin",
				"currentPlan":    "pro",
				"maxConnections": 100,
				"canConnect":     true,
				"wsapiEnabled":   true,
				"deviceCount":    100,
				"role":           "R_SUPER",
			},
		},
	})
}

func (s *Server) handleRegister(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "Đăng ký thành công",
		Data: gin.H{"userId": 1},
	})
}

func (s *Server) handleResetPassword(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "Đặt lại mật khẩu thành công",
		Data: true,
	})
}

func (s *Server) handleSendVerificationCode(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "Mã xác thực đã được gửi",
		Data: gin.H{"expireIn": 300},
	})
}

func (s *Server) handleUserInfo(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: models.UserInfo{
			UserId:         1,
			UserName:       "admin",
			CurrentPlan:    "pro",
			MaxConnections: 100,
			CanConnect:     true,
			WsapiEnabled:   true,
			DeviceCount:    100,
			ExpiryDate:     "2099-12-31",
			Role:           "R_SUPER",
		},
	})
}

func (s *Server) handleUserList(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: []gin.H{
			{
				"userId":   1,
				"userName": "admin",
				"role":     "R_SUPER",
				"status":   1,
			},
		},
	})
}

func (s *Server) handleUserLogout(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "Đăng xuất thành công",
		Data: true,
	})
}

func (s *Server) handleMenusSimple(c *gin.Context) {
	menus := []*models.MenuItem{
		{
			Name:      "Console",
			Path:      "/console",
			Component: "/dashboard/console",
			Meta: models.MenuMeta{
				Title:     "menus.dashboard.console",
				Icon:      "lucide:monitor-smartphone",
				Roles:     []string{"R_SUPER", "R_ADMIN"},
				KeepAlive: true,
				FixedTab:  true,
			},
		},
		{
			Name:      "WorkflowBuilder",
			Path:      "/workflow",
			Component: "/outside/Iframe",
			Meta: models.MenuMeta{
				Title:     "Tạo Workflow Auto",
				Icon:      "lucide:workflow",
				Roles:     []string{"R_SUPER", "R_ADMIN"},
				KeepAlive: true,
				IsIframe:  true,
				Link:      "/workflow-builder",
			},
		},
		{
			Name:      "Device",
			Path:      "/device",
			Component: "/index/index",
			Meta: models.MenuMeta{
				Title: "menus.device.title",
				Icon:  "bx:server",
				Roles: []string{"R_SUPER", "R_ADMIN"},
			},
			Children: []*models.MenuItem{
				{
					Name:      "DeviceList",
					Path:      "list",
					Component: "/device/list",
					Meta: models.MenuMeta{
						Title:     "menus.device.list",
						KeepAlive: true,
						Roles:     []string{"R_SUPER", "R_ADMIN"},
					},
				},
			},
		},
	}

	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: menus,
	})
}

func (s *Server) handleRoleList(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: []gin.H{
			{
				"roleId":   1,
				"roleName": "Super Administrator",
				"roleCode": "R_SUPER",
			},
			{
				"roleId":   2,
				"roleName": "Administrator",
				"roleCode": "R_ADMIN",
			},
		},
	})
}

func (s *Server) handleDeviceList(c *gin.Context) {
	devices := s.deviceMgr.GetAllDevices()
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: devices,
	})
}

func (s *Server) handleAppIcon(c *gin.Context) {
	// Return a 1x1 transparent PNG or empty icon
	c.Data(http.StatusOK, "image/png", []byte{})
}

func (s *Server) appendLog(msg string) {
	s.logMu.Lock()
	defer s.logMu.Unlock()
	entry := fmt.Sprintf("[%s] %s", time.Now().Format("15:04:05"), msg)
	s.logs = append(s.logs, entry)
	if len(s.logs) > 500 {
		s.logs = s.logs[len(s.logs)-500:]
	}
}

func (s *Server) getLogs() []string {
	s.logMu.RLock()
	defer s.logMu.RUnlock()
	res := make([]string, len(s.logs))
	copy(res, s.logs)
	return res
}

func (s *Server) handleWorkflowTemplates(c *gin.Context) {
	templates := workflow.GetPredefinedTemplates()
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: templates,
	})
}

func (s *Server) handleWorkflowStatus(c *gin.Context) {
	status := s.wfEngine.GetStatus()
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: status,
	})
}

func (s *Server) handleWorkflowRun(c *gin.Context) {
	var wf workflow.Workflow
	if err := c.ShouldBindJSON(&wf); err != nil {
		c.JSON(http.StatusBadRequest, models.ApiResponse{
			Code: 400,
			Msg:  "Dữ liệu workflow không hợp lệ: " + err.Error(),
		})
		return
	}

	if len(wf.Nodes) == 0 {
		c.JSON(http.StatusBadRequest, models.ApiResponse{
			Code: 400,
			Msg:  "Workflow phải chứa ít nhất 1 node chức năng",
		})
		return
	}

	// Run in background goroutine
	go func() {
		_ = s.wfEngine.Execute(context.Background(), &wf, s.appendLog)
	}()

	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "Đã khởi chạy workflow thành công",
		Data: gin.H{
			"id":   wf.ID,
			"name": wf.Name,
		},
	})
}

func (s *Server) handleWorkflowStop(c *gin.Context) {
	s.wfEngine.Stop()
	s.appendLog("Workflow đã được người dùng dừng thủ công")
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "Đã dừng workflow",
		Data: true,
	})
}

func (s *Server) handleWorkflowLogs(c *gin.Context) {
	c.JSON(http.StatusOK, models.ApiResponse{
		Code: 200,
		Msg:  "thành công",
		Data: s.getLogs(),
	})
}

func (s *Server) handleWorkflowBuilder(c *gin.Context) {
	candidates := []string{
		"D:/python/bypass_hcbox/extracted_source/workflow/index.html",
		"extracted_source/workflow/index.html",
	}
	for _, cand := range candidates {
		if _, err := os.Stat(cand); err == nil {
			c.File(cand)
			return
		}
	}
	c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(`<!DOCTYPE html>
<html>
<head><title>Workflow Builder</title></head>
<body><h2>Workflow Builder UI Loading...</h2></body>
</html>`))
}

// Router returns the underlying gin.Engine
func (s *Server) Router() *gin.Engine {
	return s.router
}

// Start runs the HTTP server
func (s *Server) Start() error {
	return s.router.Run(s.addr)
}

package routers

import (
	"backend-go/handlers"

	"backend-go/middleware"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
)

func Websocket(app *fiber.App) {

	app.Use("/ws", func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	app.Get("/ws", middleware.AuthMiddleware, websocket.New(handlers.HandleWebSocket))
}

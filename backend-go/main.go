package main

import (
	"backend-go/config"
	"backend-go/routers"
	"log"
	"os"

	_ "backend-go/docs"

	"backend-go/handlers"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	swagger "github.com/swaggo/fiber-swagger"
)

// @title           Webchat
// @version         1.0
// @description     API WEBCHAT
// @termsOfService  http://swagger.io/terms/

// @contact.name    Arya Prodigy
// @contact.email   arya@example.com

// @securityDefinitions.apikey  BearerAuth
// @in                          header
// @name                        Authorization
// @description                 Masukkan token dengan format: Bearer <token_kamu>

// @host            localhost:8080
// @BasePath        /api
// @schemes         http
func main() {
	config.LoadEnv()
	config.ConnectDatabase()

	app := fiber.New(fiber.Config{
		AppName: "E-Library API v1.0",
	})

	// start the websocket hub (will be started once before listen)

	app.Static("/uploads", "./uploads")

	app.Use(cors.New(cors.Config{
		AllowOrigins:     "http://localhost:3000,http://127.0.0.1:3000, http://localhost:8080, http://10.0.2.2:8080",
		AllowMethods:     "GET,POST,PUT,PATCH,DELETE,OPTIONS",
		AllowHeaders:     "Origin, Content-Type, Accept, Authorization, Cookie, X-Requested-With",
		ExposeHeaders:    "Set-Cookie",
		AllowCredentials: true,
	}))
	app.Use(logger.New())

	routers.SetupRoutes(app)
	routers.Websocket(app)

	app.Get("/swagger/*", swagger.WrapHandler)

	app.Get("/", func(c *fiber.Ctx) error {
		return c.Redirect("/swagger/index.html")
	})

	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	config.InitCloudinary()

	handlers.StartDefaultHub()

	log.Println(" Server running on http://localhost:" + port)
	log.Fatal(app.Listen(":" + port))
}

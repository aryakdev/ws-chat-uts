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

	app.Use(cors.New(cors.Config{
		AllowOrigins:     "*",
		AllowMethods:     "GET,POST,PUT,PATCH,DELETE,OPTIONS",
		AllowHeaders:     "Origin,Content-Type,Authorization",
		AllowCredentials: false,
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

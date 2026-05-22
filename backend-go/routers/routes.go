package routers

import (
	"backend-go/handlers"
	"backend-go/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	// --- GRUP API ---
	api := app.Group("/api")

	auth := api.Group("/auth")
	profile := api.Group("/profile", middleware.HttpMiddleware)
	user := api.Group("/users", middleware.HttpMiddleware)
	chat := api.Group("/chat", middleware.HttpMiddleware)

	// Auth
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)
	auth.Post("/refresh", handlers.RefreshToken)

	// Profile (Milik User Sendiri)
	profile.Get("/me", handlers.GetMyProfile)
	profile.Patch("/me", handlers.UpdateMyProfile)
	profile.Patch("/update/:id", handlers.UpdateProfileByID)
	profile.Patch("/avatar", handlers.UpdateAvatar)

	// Users (Admin/General)
	user.Get("/", handlers.GetUsers)
	user.Get("/:id", handlers.GetUserByID)

	//ChatRoom (Private)
	chat.Post("/private", handlers.CreateOrGetPrivateRoom)
}

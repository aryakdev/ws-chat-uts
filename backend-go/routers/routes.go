package routers

import (
	"backend-go/handlers"
	"backend-go/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {

	api := app.Group("/api")

	auth := api.Group("/auth")
	profile := api.Group("/profile", middleware.HttpMiddleware)
	user := api.Group("/users", middleware.HttpMiddleware)
	chat := api.Group("/chat", middleware.HttpMiddleware)
	messages := api.Group("/messages", middleware.HttpMiddleware)

	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)
	auth.Post("/refresh", handlers.RefreshToken)

	profile.Get(
		"/me",
		middleware.ProfileCache(),
		handlers.GetMyProfile,
	)
	profile.Patch("/me", handlers.UpdateMyProfile)
	profile.Patch("/update/:id", handlers.UpdateProfileByID)
	profile.Patch("/avatar", handlers.UpdateAvatar)

	user.Get("/", handlers.GetUsers)
	user.Get("/:id", handlers.GetUserByID)

	chat.Post("/private", handlers.CreateOrGetPrivateRoom)

	messages.Get("/", handlers.GetMessages)
	messages.Get("/:room_id", handlers.GetMessagesByRoom)
}

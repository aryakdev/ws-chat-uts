package middleware

import (
	"github.com/gofiber/fiber/v2"
)

func ProfileCache() fiber.Handler {
	return func(c *fiber.Ctx) error {
		c.Set("Cache-Control", "private , max-age=60")
		c.Set("Vary", "Authorization")
		return c.Next()
	}
}

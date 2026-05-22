package middleware

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"

	"backend-go/config"
)

func HttpMiddleware(c *fiber.Ctx) error {

	if c.Method() == "OPTIONS" {
		return c.Next()
	}

	authHeader := c.Get("Authorization")

	if authHeader == "" {
		return c.Status(401).JSON(fiber.Map{"message": "missing token"})
	}

	tokenString := authHeader
	if strings.HasPrefix(authHeader, "Bearer ") {
		tokenString = strings.TrimPrefix(authHeader, "Bearer ")
	}

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(config.GetEnv("JWT_ACCESS_SECRET")), nil
	})

	if err != nil {
		return c.Status(401).JSON(fiber.Map{"message": "invalid token"})
	}

	if !token.Valid {
		return c.Status(401).JSON(fiber.Map{"message": "token not valid"})
	}

	claims := token.Claims.(jwt.MapClaims)

	userID := claims["user_id"].(string)

	c.Locals("user_id", userID)
	return c.Next()
}

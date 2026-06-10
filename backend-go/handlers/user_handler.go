package handlers

import (
	"backend-go/model"
	"backend-go/repository"
	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func GetUsers(c *fiber.Ctx) error {
	currentUserID := c.Locals("user_id")

	fmt.Println("CURRENT USER ID:", currentUserID)

	users, err := repository.FindUsersExceptCurrentUser(currentUserID)

	if err != nil {

		return c.Status(500).JSON(fiber.Map{
			"message": "Gagal mengambil data user",
		})
	}

	result := make([]fiber.Map, 0)

	for _, u := range users {
		result = append(result, fiber.Map{
			"id":       u.ID,
			"username": u.Profile.Username,
			"avatar":   u.Profile.Avatar,
		})
	}

	return c.JSON(fiber.Map{
		"message": "Success",
		"data":    result,
	})
}

func GetUserByID(c *fiber.Ctx) error {
	idParam := c.Params("id")

	userID, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "ID tidak valid",
		})
	}

	user, err := repository.FindUserByIDWithProfile(userID)

	if err != nil {

		return c.Status(404).JSON(fiber.Map{
			"message": "User tidak ditemukan",
		})
	}

	response := model.UserDetailResponse{
		UserBaseResponse: model.UserBaseResponse{
			ID:       user.ID,
			Username: user.Profile.Username,
		},
		Email:  user.Email,
		Bio:    user.Profile.Bio,
		Avatar: user.Profile.Avatar,
	}

	return c.JSON(fiber.Map{
		"message": "Success",
		"data":    response,
	})
}

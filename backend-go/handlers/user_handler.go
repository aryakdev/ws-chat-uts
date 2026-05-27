package handlers

import (
	"backend-go/config"
	"backend-go/model"

	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// GetUsers godoc
// @Summary      Get semua user
// @Description  Mengambil daftar semua user (tanpa detail)
// @Tags         Users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{} "Success response"
// @Failure      500  {object}  model.ErrorResponse
// @Router       /users [get]
func GetUsers(c *fiber.Ctx) error {
	var users []model.User

	currentUserID := c.Locals("user_id")

	fmt.Println("CURRENT USER ID:", currentUserID)

	if err := config.DB.
		Preload("Profile").
		Where("id != ?", currentUserID).
		Find(&users).Error; err != nil {

		return c.Status(500).JSON(fiber.Map{
			"message": "Gagal mengambil data user",
		})
	}

	result := make([]model.UserBaseResponse, 0)

	for _, u := range users {
		result = append(result, model.UserBaseResponse{
			ID:       u.ID,
			Username: u.Profile.Username,
		})
	}

	return c.JSON(fiber.Map{
		"message": "Success",
		"data":    result,
	})
}

// GetUserByID godoc
// @Summary      Get detail user
// @Description  Mengambil detail user berdasarkan ID
// @Tags         Users
// @Accept       json
// @Produce      json
// @Param        id   path      string  true  "User ID (UUID)"
// @Success      200  {object}  map[string]interface{} "Success response"
// @Failure      400  {object}  model.ErrorResponse
// @Failure      404  {object}  model.ErrorResponse
// @Router       /users/{id} [get]
func GetUserByID(c *fiber.Ctx) error {
	idParam := c.Params("id")

	userID, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "ID tidak valid",
		})
	}

	var user model.User

	// ambil user + profile
	if err := config.DB.Preload("Profile").
		Where("id = ?", userID).
		Limit(20).
		First(&user).Error; err != nil {

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

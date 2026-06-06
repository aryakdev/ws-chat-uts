package handlers

import (
	"backend-go/model"
	"backend-go/repository"

	"github.com/gofiber/fiber/v2"
)

// GetRoomPrivate godoc
//
//	@Summary		Get or Create Private Room
//	@Description	Check existing private room between users or create new one
//	@Tags			Chat
//	@Accept			json
//	@Produce		json
//	@Param			request	body		model.CreateOrGetPrivateRoomRequest	true	"Target User ID"
//	@Success		200		{object}	map[string]interface{}
//
// @Security     BearerAuth
//
//	@Failure		400		{object}	map[string]interface{}
//
// @Router /chat/private [post]
func CreateOrGetPrivateRoom(c *fiber.Ctx) error {

	var req model.CreateOrGetPrivateRoomRequest

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Invalid body",
		})
	}

	currentUserID := c.Locals("user_id").(string)

	if currentUserID == req.TargetUserID {
		return c.Status(400).JSON(fiber.Map{
			"message": "Cannot chat with yourself",
		})
	}

	// 1. cek room dulu
	roomID, err := repository.FindPrivateRoom(currentUserID, req.TargetUserID)

	if err == nil {
		return c.JSON(fiber.Map{
			"message": "Room found",
			"room_id": roomID,
		})
	}

	// 2. kalau tidak ada → CREATE ROOM
	roomID, err = repository.CreatePrivateRoom(currentUserID, req.TargetUserID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Failed to create room",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Room created",
		"room_id": roomID,
	})
}

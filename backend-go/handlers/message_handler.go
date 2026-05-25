package handlers

import (
	"backend-go/config"
	"backend-go/model"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// GetMessages godoc
// @Summary      Get All Messages
// @Description  Mengambil semua pesan
// @Tags         Messages
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  model.MessageResponse
// @Failure      500  {object}  map[string]string
// @Router       /messages [get]
func GetMessages(c *fiber.Ctx) error {
	var messages []model.Message

	if err := config.DB.Preload("Sender").Find(&messages).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Gagal mengambil pesan",
		})
	}

	var result []model.MessageResponse
	for _, m := range messages {
		result = append(result, model.MessageResponse{
			ID:        m.ID.String(),
			RoomID:    m.ChatRoomID.String(),
			SenderID:  m.SenderID.String(),
			Content:   m.Content,
			Type:      m.Type,
			CreatedAt: m.CreatedAt,
		})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"data":    result,
	})
}

// GetMessagesByRoom godoc
// @Summary      Get Messages By Room
// @Description  Mengambil semua pesan berdasarkan room ID
// @Tags         Messages
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        room_id  path  string  true  "Room ID (UUID)"
// @Success      200  {object}  model.MessageResponse
// @Failure      400  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /messages/{room_id} [get]
func GetMessagesByRoom(c *fiber.Ctx) error {
	roomID, err := uuid.Parse(c.Params("room_id"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Format room_id tidak valid",
		})
	}

	var messages []model.Message

	if err := config.DB.Preload("Sender").
		Where("chat_room_id = ?", roomID).
		Find(&messages).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Gagal mengambil pesan",
		})
	}

	var result []model.MessageResponse
	for _, m := range messages {
		result = append(result, model.MessageResponse{
			ID:        m.ID.String(),
			RoomID:    m.ChatRoomID.String(),
			SenderID:  m.SenderID.String(),
			Content:   m.Content,
			Type:      m.Type,
			CreatedAt: m.CreatedAt,
		})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"data":    result,
	})
}

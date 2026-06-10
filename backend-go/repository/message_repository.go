package repository

import (
	"backend-go/config"
	"backend-go/model"

	"github.com/google/uuid"
)

func CreateMessage(message *model.Message) error {
	return config.DB.Create(message).Error
}

func GetMessages() ([]model.Message, error) {
	var messages []model.Message
	err := config.DB.Preload("Sender").
		Find(&messages).
		Limit(30).
		Error
	return messages, err
}

func GetMessagesByRoom(roomID uuid.UUID) ([]model.Message, error) {
	var messages []model.Message
	err := config.DB.Preload("Sender").
		Where("chat_room_id = ?", roomID).
		Find(&messages).Error
	return messages, err
}

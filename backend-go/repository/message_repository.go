package repository

import (
	"backend-go/config"
	"backend-go/model"
)

func CreateMessage(message *model.Message) error {
	return config.DB.Create(message).Error
}

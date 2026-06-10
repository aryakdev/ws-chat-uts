package repository

import (
	"backend-go/config"
	"backend-go/model"

	"github.com/google/uuid"
)

func FindUsersExceptCurrentUser(currentUserID interface{}) ([]model.User, error) {
	var users []model.User
	err := config.DB.
		Preload("Profile").
		Where("id != ?", currentUserID).
		Find(&users).Error
	return users, err
}

func FindUserByIDWithProfile(userID uuid.UUID) (model.User, error) {
	var user model.User
	err := config.DB.Preload("Profile").
		Where("id = ?", userID).
		Limit(20).
		First(&user).Error
	return user, err
}

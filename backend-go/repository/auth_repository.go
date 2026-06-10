package repository

import (
	"backend-go/config"
	"backend-go/model"
)

func FindUserByEmail(email string) (model.User, error) {
	var user model.User
	err := config.DB.Where("email = ?", email).First(&user).Error
	return user, err
}

func CreateUserWithProfile(user *model.User, profile *model.Profile) (string, error) {
	tx := config.DB.Begin()

	if err := tx.Create(user).Error; err != nil {
		tx.Rollback()
		return "user", err
	}

	if err := tx.Create(profile).Error; err != nil {
		tx.Rollback()
		return "profile", err
	}

	tx.Commit()
	return "", nil
}

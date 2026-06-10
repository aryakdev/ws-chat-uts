package repository

import (
	"backend-go/config"
	"backend-go/model"
	"errors"

	"gorm.io/gorm"
)

func IsRecordNotFound(err error) bool {
	return errors.Is(err, gorm.ErrRecordNotFound)
}

func FindProfileByUserID(userID interface{}) (model.Profile, error) {
	var profile model.Profile
	err := config.DB.Where("user_id = ?", userID).First(&profile).Error
	return profile, err
}

func CreateProfile(profile *model.Profile) error {
	return config.DB.Create(profile).Error
}

func SaveProfile(profile *model.Profile) error {
	return config.DB.Save(profile).Error
}

package repository

import (
	"backend-go/config"
	"backend-go/model"
	"errors"

	"gorm.io/gorm"
)

func FindPrivateRoom(currentUserID string, targetUserID string) (string, error) {
	query := `
	SELECT chat_room_id
	from chat_members
	WHERE user_id = ?

	INTERSECT

	SELECT cm.chat_room_id
	FROM chat_members cm
	JOIN chat_Rooms cr ON cr.id = cm.chat_room_id
	WHERE cm.user_id = ? AND cr.is_group = false
	LIMIT 1;
`

	var roomID string

	err := config.DB.Raw(query, currentUserID, targetUserID).Scan(&roomID).Error
	if err != nil {
		return "", err
	}

	if roomID == "" {
		return "", errors.New("room not found")
	}

	return roomID, nil
}

func CreatePrivateRoom(userA, userB string) (string, error) {

	var room model.ChatRoom

	err := config.DB.Transaction(func(tx *gorm.DB) error {

		// 1. create room
		room = model.ChatRoom{
			IsGroup: false,
		}

		if err := tx.Create(&room).Error; err != nil {
			return err
		}

		// 2. insert members
		members := []model.ChatMember{
			{
				UserID:     userA,
				ChatRoomID: room.ID,
			},
			{
				UserID:     userB,
				ChatRoomID: room.ID,
			},
		}

		if err := tx.Create(&members).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		return "", err
	}

	return room.ID, nil
}

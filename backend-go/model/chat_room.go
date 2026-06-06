package model

import (
	"time"
)

type ChatRoom struct {
	ID        string    `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	Name      *string   `json:"name,omitempty"`
	IsGroup   bool      `gorm:"default:false" json:"is_group"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type ChatMember struct {
	ID         string    `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	UserID     string    `gorm:"type:uuid;not null;index" json:"user_id"`
	ChatRoomID string    `gorm:"type:uuid;not null;index" json:"chat_room_id"`
	Role       string    `gorm:"type:varchar(20);default:'member'" json:"role"`
	JoinedAt   time.Time `gorm:"autoCreateTime" json:"joined_at"`
}

type CreateOrGetPrivateRoomRequest struct {
	TargetUserID string `json:"target_user_id"`
}

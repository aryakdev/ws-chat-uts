package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Message struct {
	ID         uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	ChatRoomID uuid.UUID `gorm:"type:uuid;not null"`
	Content    string    `gorm:"type:text;not null"`
	Type       string    `gorm:"type:varchar(20);default:'text'"`
	CreatedAt  time.Time
	UpdatedAt  time.Time
	DeletedAt  gorm.DeletedAt `gorm:"index"`

	SenderID uuid.UUID `gorm:"type:uuid;not null"`
	Sender   User      `gorm:"foreignKey:SenderID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}

type MessageRead struct {
	ID uuid.UUID

	MessageID uuid.UUID
	Message   Message `gorm:"foreignKey:MessageID"`

	UserID uuid.UUID
	User   User `gorm:"foreignKey:UserID"`

	ReadAt time.Time
}

type SendMessageRequest struct {
	RoomID  string `json:"room_id"`
	Content string `json:"content"`
	Type    string `json:"type"`
}

type MessageResponse struct {
	ID        string    `json:"id"`
	RoomID    string    `json:"room_id"`
	SenderID  string    `json:"sender_id"`
	Content   string    `json:"content"`
	Type      string    `json:"type"`
	CreatedAt time.Time `json:"created_at"`
}

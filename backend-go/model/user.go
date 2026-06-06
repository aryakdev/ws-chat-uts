package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey"`
	Email     string    `gorm:"unique;not null" json:"email"`
	Password  string    `json:"password" example:"rahasia123"`
	Profile   Profile   `gorm:"foreignKey:UserID"`
	CreatedAt time.Time `json:"created_at"`
}

type Profile struct {
	ID       uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	UserID   uuid.UUID `gorm:"type:uuid;uniqueIndex" json:"user_id"`
	Username string    `gorm:"unique;not null" json:"username"`
	Bio      string    `json:"bio"`
	Avatar   string    `json:"avatar"`
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type AuthResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	User         User   `json:"user"`
}

type ErrorResponse struct {
	Message string `json:"message"`
}

// Endpoint Profile
type ProfileResponse struct {
	Username string `json:"username"`
	Bio      string `json:"bio"`
	Avatar   string `json:"avatar"`
}

type UpdateProfileRequest struct {
	Username string `json:"username"`
	Bio      string `json:"bio"`
	Avatar   string `json:"avatar"`
}

// Endpoint user
type UserBaseResponse struct {
	ID       uuid.UUID `json:"id"`
	Username string    `json:"username"`
}

type UserResponse struct {
	UserBaseResponse
}

type UserDetailResponse struct {
	UserBaseResponse
	Email  string `json:"email"`
	Bio    string `json:"bio"`
	Avatar string `json:"avatar"`
}

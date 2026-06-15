package model

import (
	"github.com/gofiber/websocket/v2"
)

type Subscription struct {
	Conn   *websocket.Conn
	RoomID string
	UserID string
}

type BroadcastRequest struct {
	RoomID string
	Msg    []byte
}

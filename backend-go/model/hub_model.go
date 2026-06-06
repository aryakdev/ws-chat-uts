package model

import (
	"github.com/gofiber/websocket/v2"
)

type Subscription struct {
	RoomID string
	Conn   *websocket.Conn
}

type BroadcastReq struct {
	RoomID  string
	Message []byte
}

type Hub struct {
	register   chan Subscription
	unregister chan Subscription
	broadcast  chan BroadcastReq

	rooms map[string]map[*websocket.Conn]bool
}

package handlers

import (
	"encoding/json"
	"log"

	"github.com/gofiber/websocket/v2"
)

// Subscription represents a client's registration to a room
type Subscription struct {
	Conn   *websocket.Conn
	RoomID string
	UserID string
}

// BroadcastRequest represents a message to broadcast to a room
type BroadcastRequest struct {
	RoomID string
	Msg    []byte
}

// Hub handles room subscriptions and broadcasting messages
type Hub struct {
	register   chan Subscription
	unregister chan Subscription
	broadcast  chan BroadcastRequest
	rooms      map[string]map[*websocket.Conn]bool
}

// NewHub creates and returns a new Hub instance
func NewHub() *Hub {
	return &Hub{
		register:   make(chan Subscription),
		unregister: make(chan Subscription),
		broadcast:  make(chan BroadcastRequest),
		rooms:      make(map[string]map[*websocket.Conn]bool),
	}
}

// DefaultHub is a ready-to-use hub instance
var DefaultHub = NewHub()

// Run starts the main loop for the hub. This should be run as a goroutine.
func (h *Hub) Run() {
	for {
		select {
		case sub := <-h.register:
			conns, ok := h.rooms[sub.RoomID]
			if !ok {
				conns = make(map[*websocket.Conn]bool)
				h.rooms[sub.RoomID] = conns
			}
			h.rooms[sub.RoomID][sub.Conn] = true
			log.Printf("hub: register conn room=%s user=%s", sub.RoomID, sub.UserID)

		case sub := <-h.unregister:
			if conns, ok := h.rooms[sub.RoomID]; ok {
				if _, exists := conns[sub.Conn]; exists {
					delete(conns, sub.Conn)
					// attempt to close conn (safe if already closed)
					err := sub.Conn.Close()
					if err != nil {
						log.Printf("hub: error closing conn: %v", err)
					}
					log.Printf("hub: unregister conn room=%s user=%s", sub.RoomID, sub.UserID)
				}
				if len(conns) == 0 {
					delete(h.rooms, sub.RoomID)
				}
			}

		case b := <-h.broadcast:
			if conns, ok := h.rooms[b.RoomID]; ok {
				for conn := range conns {
					if err := conn.WriteMessage(websocket.TextMessage, b.Msg); err != nil {
						log.Printf("hub: write error room=%s err=%v", b.RoomID, err)
						// close and remove conn on error
						conn.Close()
						delete(conns, conn)
					}
				}
			}
		}
	}
}

// StartDefaultHub launches the default hub loop in a goroutine.
func StartDefaultHub() {
	go DefaultHub.Run()
}

// Register registers a connection to a room on the default hub.
func WsRegister(conn *websocket.Conn, roomID string, userID string) {
	DefaultHub.register <- Subscription{Conn: conn, RoomID: roomID, UserID: userID}
}

// Unregister removes a connection from a room on the default hub.
func Unregister(conn *websocket.Conn, roomID string, userID string) {
	DefaultHub.unregister <- Subscription{Conn: conn, RoomID: roomID, UserID: userID}
}

// Broadcast sends raw bytes to all connections in a room via the default hub.
func Broadcast(roomID string, msg []byte) {
	DefaultHub.broadcast <- BroadcastRequest{RoomID: roomID, Msg: msg}
}

// BroadcastJSON marshals v to JSON and broadcasts it to the room.
func BroadcastJSON(roomID string, v interface{}) error {
	b, err := json.Marshal(v)
	if err != nil {
		return err
	}
	Broadcast(roomID, b)
	return nil
}

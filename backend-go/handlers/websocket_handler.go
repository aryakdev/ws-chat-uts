package handlers

import (
	"encoding/json"
	"log"

	"backend-go/model"
	"backend-go/repository"

	"github.com/gofiber/websocket/v2"
	"github.com/google/uuid"
)

func HandleWebSocket(conn *websocket.Conn) {

	defer conn.Close()

	userID := conn.Locals("user_id").(string)

	log.Println("USER CONNECTED:", userID)

	var currentRoomID string

	defer func() {
		if currentRoomID != "" {
			Unregister(conn, currentRoomID, userID)
		}
	}()

	for {

		_, msg, err := conn.ReadMessage()
		if err != nil {
			log.Println("Read Error:", err)
			break
		}

		var req model.SendMessageRequest

		err = json.Unmarshal(msg, &req)
		if err != nil {
			log.Println("Invalid JSON:", err)
			continue
		}

		switch req.Action {

		case "join":
			if currentRoomID != "" && currentRoomID != req.RoomID {
				Unregister(conn, currentRoomID, userID)
				log.Printf("ws: left room=%s user=%s", currentRoomID, userID)
			}
			currentRoomID = req.RoomID
			WsRegister(conn, req.RoomID, userID)
			log.Printf("ws: joined room=%s user=%s", req.RoomID, userID)

		case "leave":
			if currentRoomID == req.RoomID {
				Unregister(conn, req.RoomID, userID)
				currentRoomID = ""
				log.Printf("ws: left room=%s user=%s", req.RoomID, userID)
			}

		case "message":

			if currentRoomID == "" {
				log.Printf("ws: message rejected, user=%s has not joined any room", userID)
				continue
			}

			roomUUID, err := uuid.Parse(req.RoomID)
			if err != nil {
				log.Println("Invalid Room ID:", err)
				continue
			}

			senderUUID, err := uuid.Parse(userID)
			if err != nil {
				log.Println("Invalid Sender UUID:", err)
				continue
			}

			message := model.Message{
				ChatRoomID: roomUUID,
				Content:    req.Content,
				Type:       req.Type,
				SenderID:   senderUUID,
			}

			err = repository.CreateMessage(&message)
			if err != nil {
				log.Println("DB Error:", err)
				continue
			}

			response := model.MessageResponse{
				ID:        message.ID.String(),
				RoomID:    message.ChatRoomID.String(),
				SenderID:  message.SenderID.String(),
				Content:   message.Content,
				Type:      message.Type,
				CreatedAt: message.CreatedAt,
			}

			err = BroadcastJSON(req.RoomID, response)
			if err != nil {
				log.Println("Broadcast Error:", err)
				continue
			}

		default:
			log.Printf("ws: unknown action=%q user=%s", req.Action, userID)
		}
	}
}

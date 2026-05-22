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

		jsonResponse, err := json.Marshal(response)
		if err != nil {
			log.Println("Marshal Error:", err)
			continue
		}

		err = conn.WriteMessage(websocket.TextMessage, jsonResponse)
		if err != nil {
			log.Println("Write Error:", err)
			break
		}
	}
}

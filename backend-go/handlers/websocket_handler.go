package handlers

import (
	"log"

	"github.com/gofiber/websocket/v2"
)

func HandleWebSocket(conn *websocket.Conn) {
	defer conn.Close()

	log.Println("Client Connected")

	for {
		messageType, msg, err := conn.ReadMessage()
		if err != nil {
			log.Println(err)
			break
		}

		err = conn.WriteMessage(messageType, msg)
		if err != nil {
			log.Println("Write Error:", err)
			break
		}
	}
}

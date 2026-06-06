package handlers

import (
	"log"

	"github.com/gofiber/websocket/v2"
)

func WsHandler(c *websocket.Conn) {
	log.Println("🔥 Koneksi WebSocket baru berhasil terhubung!")

	// Looping untuk mendengarkan pesan dari Flutter
	for {
		mt, msg, err := c.ReadMessage()
		if err != nil {
			log.Println("Koneksi WS terputus:", err)
			break
		}

		log.Printf("Pesan dari Flutter: %s", msg)

		// Balas ke Flutter (Echo)
		err = c.WriteMessage(mt, []byte("Server menerima pesanmu: "+string(msg)))
		if err != nil {
			log.Println("Gagal membalas pesan WS:", err)
			break
		}
	}
}

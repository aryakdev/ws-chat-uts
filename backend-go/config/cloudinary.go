package config

import (
	"log"
	"os"

	"github.com/cloudinary/cloudinary-go/v2"
)

var Cloudinary *cloudinary.Cloudinary

func InitCloudinary() {

	cloudinaryURL := os.Getenv("CLOUDINARY_URL")

	if cloudinaryURL == "" {
		log.Fatal("CLOUDINARY_URL belum diatur")
	}

	cld, err := cloudinary.NewFromURL(cloudinaryURL)

	if err != nil {
		log.Fatal("Gagal init Cloudinary:", err)
	}

	cld.Config.URL.Secure = true

	Cloudinary = cld

	log.Println("✅ Cloudinary connected")
}

package handlers

import (
	"log"

	"github.com/cloudinary/cloudinary-go/v2"
)

var Cloudinary *cloudinary.Cloudinary

func InitCloudinary() {

	cld, err := cloudinary.New()

	if err != nil {
		log.Fatal("Cloudinary error:", err)
	}

	cld.Config.URL.Secure = true

	Cloudinary = cld
}

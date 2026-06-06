package config

import (
	model "backend-go/model"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func LoadEnv() {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file not found, using environment variables")
	}
}

func GetEnv(key string) string {
	return os.Getenv(key)
}

var DB *gorm.DB

func ConnectDatabase() {
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")

	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		host, user, password, dbname, port,
	)

	newLogger := logger.New(
		log.New(os.Stdout, "\r\n", log.LstdFlags),
		logger.Config{

			LogLevel: logger.Error,
		},
	)

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: newLogger,
	})

	if err != nil {
		log.Fatal("Gagal terhubung ke database: ", err)
	}

	fmt.Println("Berhasil terhubung ke database PostgreSQL!")
	fmt.Println("DB_HOST:", host)
	fmt.Println("DB_PORT:", port)

	DB = database

	fmt.Println("Menjalankan Auto-Migration...")
	err = DB.AutoMigrate(
		&model.User{},
		&model.Profile{},
		&model.ChatRoom{},
		&model.ChatMember{},
		&model.Message{},
		&model.MessageRead{})

	if err != nil {
		log.Fatal("Gagal melakukan Auto-Migration: ", err)
	}

	fmt.Println("Auto-Migration berhasil dan database siap digunakan!")
}

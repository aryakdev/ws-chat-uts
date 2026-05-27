package handlers

import (
	"backend-go/config"
	"backend-go/model"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

// Register godoc
// @Summary Daftar User WebSystem
// @Description Membuat akun baru untuk mengakses API yang diproteksi
// @Tags Auth
// @Accept json
// @Produce json
// @Param user body model.RegisterRequest true "Username & Password"
// @Success 201 {object} map[string]string
// @Router /auth/register [post]
func Register(c *fiber.Ctx) error {
	var req model.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Format data tidak valid"})
	}

	if strings.TrimSpace(req.Username) == "" || !strings.Contains(req.Email, "@") || len(req.Password) < 8 {
		return c.Status(400).JSON(fiber.Map{"message": "Validasi gagal. Pastikan email valid dan password minimal 8 karakter"})
	}

	var existingUser model.User
	if err := config.DB.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		return c.Status(409).JSON(fiber.Map{"message": "Email sudah terdaftar"})
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Password terlalu panjang"})
	}

	tx := config.DB.Begin()

	user := model.User{
		ID:       uuid.New(),
		Email:    req.Email,
		Password: string(hashedPassword),
	}
	if err := tx.Create(&user).Error; err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"message": "Gagal Membuat User"})
	}
	profile := model.Profile{
		ID:       uuid.New(),
		UserID:   user.ID,
		Username: req.Username,
	}

	if err := tx.Create(&profile).Error; err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"message": "Gagal Membuat Profile User"})
	}

	tx.Commit()
	return c.Status(201).JSON(fiber.Map{"message": "Register berhasil", "user_id": user.ID})
}

// Login godoc
// @Summary      Login User
// @Description  Masukan username & password untuk mendapatkan token JWT
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        login  body      model.LoginRequest  true  "Username & Password"
// @Success      200    {object}  map[string]string
// @Router /auth/login [post]
func Login(c *fiber.Ctx) error {
	var req model.LoginRequest
	var user model.User

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Gagal parsing data"})
	}

	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Email tidak ditemukan"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Password salah"})
	}

	accessSecret := config.GetEnv("JWT_ACCESS_SECRET")
	refreshSecret := config.GetEnv("JWT_REFRESH_SECRET")

	accessClaims := jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(60 * time.Minute).Unix(),
	}
	atToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	at, err := atToken.SignedString([]byte(accessSecret))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal generate token"})
	}

	refreshClaims := jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(7 * 24 * time.Hour).Unix(),
	}
	rtToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	rt, err := rtToken.SignedString([]byte(refreshSecret))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal generate token"})
	}

	cookie := new(fiber.Cookie)
	cookie.Name = "refresh_token"
	cookie.Value = rt
	cookie.Expires = time.Now().Add(7 * 24 * time.Hour)
	cookie.HTTPOnly = true
	cookie.SameSite = "Lax"
	c.Cookie(cookie)

	return c.JSON(fiber.Map{
		"message":       "Login berhasil",
		"access_token":  at,
		"refresh_token": rt,
		"user_id":       user.ID,
	})
}

// Refresh godoc
// @Summary      Refresh Access Token
// @Description  Menghasilkan access token baru menggunakan refresh token dari cookie
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Success      200 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Router       /auth/refresh [post]
func RefreshToken(c *fiber.Ctx) error {
	rt := c.Cookies("refresh_token")

	token, err := jwt.Parse(rt, func(token *jwt.Token) (interface{}, error) {
		return []byte(config.GetEnv("JWT_REFRESH_SECRET")), nil
	})

	if err != nil || !token.Valid {
		return c.Status(401).JSON(fiber.Map{"message": "Invalid refresh token"})
	}

	claims := token.Claims.(jwt.MapClaims)

	newClaims := jwt.MapClaims{
		"user_id": claims["user_id"],
		"exp":     time.Now().Add(15 * time.Minute).Unix(),
	}

	newToken := jwt.NewWithClaims(jwt.SigningMethodHS256, newClaims)
	at, err := newToken.SignedString([]byte(config.GetEnv("JWT_REFRESH_SECRET")))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal generate access token"})
	}

	return c.JSON(fiber.Map{
		"access_token": at,
	})
}

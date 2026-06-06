# ws-chat-uts

Aplikasi **real-time chat** berbasis **WebSocket** dengan arsitektur terpisah antara backend dan frontend. Proyek ini saat ini masih dalam tahap **development**, sehingga fitur chat end-to-end dapat terus berkembang seiring iterasi.

## 1 Deskripsi Project

`ws-chat-uts` adalah proyek aplikasi chat yang dirancang untuk komunikasi real-time.

- **Backend (Golang)** menangani API, autentikasi, dan orkestrasi layanan.
- **Frontend (Flutter)** menjadi client mobile untuk interaksi pengguna.
- **PostgreSQL** digunakan sebagai penyimpanan data utama.
- **Redis** disiapkan untuk kebutuhan caching/pub-sub realtime.
- Seluruh service backend dijalankan melalui **Docker Compose**.

> Status saat ini: development (pengembangan aktif).

---

## 2) Tech Stack

- **Golang** (backend API/service)
- **Flutter** (aplikasi mobile)
- **PostgreSQL** (database utama)
- **Redis** (cache & messaging pendukung realtime)
- **Docker & Docker Compose** (container orchestration lokal)

---

## 3) Struktur Folder

Berikut struktur utama project:

```text
ws-chat-uts/
├── backend-go/
├── mobile_flutter/
├── database/
├── docker-compose.yml
├── .env.example
└── README.md
```

### Penjelasan singkat tiap folder

- **`backend-go/`**  
  Berisi source code backend Golang (konfigurasi, handler, middleware, model, routing, dokumentasi Swagger, dan entry point aplikasi).

- **`mobile_flutter/`** *(catatan: ini folder frontend yang ada di repository saat ini)*  
  Berisi source code aplikasi Flutter (UI, state, model, dan konfigurasi multiplatform Android/iOS/Web/Desktop).

- **`database/`**  
  Berisi kebutuhan inisialisasi database (contoh: skrip SQL awal).

- **`docker-compose.yml`**  
  Definisi service container (backend, PostgreSQL, Redis) dan networking antar-service.

- **`.env.example`**  
  Contoh variabel environment minimum untuk koneksi database.

> Jika Anda menggunakan istilah `flutter_mobile`, pada repository ini padanannya adalah folder **`mobile_flutter/`**.

---

## 4) Cara Menjalankan Project

### Prasyarat

Pastikan sudah terpasang:

- Docker + Docker Compose
- Flutter SDK
- Git

### Langkah-langkah

1. **Clone repository**

```bash
git clone <url-repository-anda>
cd ws-chat-uts
```

2. **Siapkan environment file**

```bash
cp .env.example .env
```

Lalu isi nilai variabel pada `.env` sesuai kebutuhan.

3. **Jalankan service backend + database + redis**

```bash
docker compose up --build
```

4. **Pastikan semua service berjalan**

- `chat-backend` (backend)
- `chat-db` (PostgreSQL)
- `chat-redis` (Redis)

Cek status service:

```bash
docker compose ps
```

5. **Jalankan frontend Flutter (terpisah dari Docker Compose)**

Buka terminal baru, lalu:

```bash
cd mobile_flutter
flutter pub get
flutter run
```

---

## 5) Environment

Project menggunakan environment variables untuk konfigurasi koneksi.

### Minimal variabel (berdasarkan `.env.example`)

```env
DB_USER=<username_db>
DB_PASSWORD=<password_db>
DB_NAME=<nama_db>
```

### Variabel yang juga digunakan service backend

```env
DB_HOST=db
DB_PORT=5432
APP_PORT=8080
REDIS_HOST=redis
REDIS_PORT=6379
JWT_SECRET=<secret_token>
```

> `DB_HOST=db` dan `REDIS_HOST=redis` mengikuti nama service pada Docker Compose internal network.

---

## 6) API / WebSocket Info

### API utama (saat ini)

Base path backend:

```text
/api
```

Endpoint yang sudah tersedia antara lain:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/profile/me` (memerlukan JWT)
- `PATCH /api/profile/me` (memerlukan JWT)

Dokumentasi Swagger:

- `GET /swagger/index.html`

### WebSocket

- Endpoint WebSocket umum untuk chat biasanya berada pada path seperti:

```text
/ws
```

- Pada versi saat ini, route WebSocket chat belum diekspos di routing utama backend (masih tahap pengembangan).

Contoh koneksi WebSocket (saat endpoint tersedia):

```text
ws://localhost:8080/ws
```

---

## 7) Catatan Tambahan

- Pastikan Docker daemon aktif sebelum menjalankan `docker compose up --build`.
- Pastikan Flutter SDK siap (`flutter doctor` tidak ada error kritis).
- Jika port bentrok, sesuaikan mapping port pada `docker-compose.yml`.
- Untuk development, jalankan backend via Docker Compose dan frontend secara lokal agar iterasi UI lebih cepat.

---

## Lisensi

Tambahkan informasi lisensi sesuai kebijakan project (mis. MIT, Apache-2.0, atau private internal).

## 8) Database Diagram

The current database relationship diagram is available at:

- [Open Database Diagram (draw.io)](https://app.diagrams.net/?src=about#G1IQlvp4MQX225xthIo7t2NS_L4aQSXnYF#%7B%22pageId%22%3A%22kfpf0aNp-GbPhx4jT6oY%22%7D)

---

## 9) API Endpoints

This section documents all currently registered HTTP and WebSocket routes in the backend service.

### Health / Root

#### GET /

- **Description:** Redirects to Swagger UI.
- **Request body:** Not required.
- **Response example:** HTTP 302 redirect to `/swagger/index.html`.

### Swagger

#### GET /swagger/*

- **Description:** Serves Swagger API documentation UI.
- **Request body:** Not required.
- **Response example:** Swagger HTML page.

### WebSocket

#### GET /ws

- **Description:** Upgrades HTTP connection to WebSocket and starts chat echo handler.
- **Request body:** Not required (WebSocket handshake).
- **Response example:**

```json
{
  "event": "message",
  "payload": "Server menerima pesanmu: <your_message>"
}
```

> Note: Accessing `/ws` without a valid WebSocket upgrade returns `426 Upgrade Required`.

### Auth

#### POST /api/auth/register

- **Description:** Registers a new user account and creates a linked profile record.
- **Request:**

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123"
}
```

- **Response example (201):**

```json
{
  "message": "Register berhasil",
  "user_id": "6e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d"
}
```

#### POST /api/auth/login

- **Description:** Authenticates a user and returns a JWT token (also set in HTTP-only cookie `token`).
- **Request:**

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

- **Response example (200):**

```json
{
  "message": "Login berhasil",
  "token": "jwt_token_here",
  "user_id": "6e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d"
}
```

### Profile

#### GET /api/profile/me

- **Description:** Returns the authenticated user's profile.
- **Authentication:** Bearer token required.
- **Request body:** Not required.
- **Response example (200):**

```json
{
  "username": "john_doe",
  "bio": "Backend engineer",
  "avatar": "https://example.com/avatar.jpg"
}
```

#### PATCH /api/profile/me

- **Description:** Updates the authenticated user's profile fields.
- **Authentication:** Bearer token required.
- **Request:**

```json
{
  "username": "john_doe_updated",
  "bio": "Building realtime apps",
  "avatar": "https://example.com/new-avatar.jpg"
}
```

- **Response example (200):**

```json
{
  "message": "profile updated",
  "data": {
    "id": "1e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d",
    "user_id": "6e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d",
    "username": "john_doe_updated",
    "bio": "Building realtime apps",
    "avatar": "https://example.com/new-avatar.jpg"
  }
}
```

#### PATCH /patch/update/:id

- **Description:** Updates (or initializes) profile data by user ID for integration compatibility with mobile client.
- **Request:**

```json
{
  "username": "john_doe_updated",
  "bio": "Cross-platform user",
  "avatar": "https://example.com/avatar.jpg"
}
```

- **Response example (200):**

```json
{
  "message": "Profile berhasil diperbarui",
  "data": {
    "id": "1e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d",
    "user_id": "6e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d",
    "username": "john_doe_updated",
    "bio": "Cross-platform user",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

### Users

#### GET /api/users/

- **Description:** Returns list of users (ID and username).
- **Request body:** Not required.
- **Response example (200):**

```json
{
  "message": "Success",
  "data": [
    {
      "id": "6e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d",
      "username": "john_doe"
    }
  ]
}
```

#### GET /api/users/:id

- **Description:** Returns user detail by UUID.
- **Request body:** Not required.
- **Response example (200):**

```json
{
  "message": "Success",
  "data": {
    "id": "6e2ad4ec-7a14-452d-a6f8-5f8ab5a2f89d",
    "username": "john_doe",
    "email": "john@example.com",
    "bio": "Backend engineer",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

---

## 10) Integration Contract

This section defines backend integration expectations for web, mobile, and other clients.

### CORS Configuration

- The backend accepts cross-origin requests via Fiber CORS middleware.
- Development origins currently include localhost variants for Flutter Web and API development.
- For production, use explicit trusted origins instead of wildcard (`*`) to improve security.

### Base URL

- Current API group base path:

```text
/api
```

- Endpoint convention example:

```text
/api/auth/login
/api/profile/me
/api/users/
```

### Response Schema

- All responses are JSON.
- Key names currently use **snake_case** for multi-word fields (for example: `user_id`, `created_at`) and lowercase key naming for simple fields (`message`, `data`).
- Typical success and error envelope patterns used in this project:

```json
{
  "message": "success",
  "data": {},
  "error": null
}
```

```json
{
  "message": "error message"
}
```

---

## 11) Repository Standards

### Git Flow

- Use small, descriptive commits for each logical change.
- Use feature branches for ongoing work (for example: `feature/auth-improvements`, `feature/chat-room`).
- Open pull requests for review before merging into the main branch.

### .gitignore

Ensure `.gitignore` includes at least:

- `node_modules/`
- `.env`
- Build outputs/binaries (for example: `bin/`, compiled artifacts)

### Environment Variables

- Store runtime configuration in `.env`.
- Keep `.env.example` as the template for required variables.
- Never commit real secrets or production credentials.
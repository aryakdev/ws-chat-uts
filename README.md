# ws-chat-uts

`ws-chat-uts` adalah aplikasi chat real-time berbasis **Go Fiber**, **WebSocket**, **PostgreSQL**, dan **Flutter**. Repository ini berisi dua bagian utama:

- **`backend-go/`**: REST API, autentikasi JWT, WebSocket chat room, upload avatar Cloudinary, dan migrasi database otomatis dengan GORM.
- **`mobile_flutter/`**: client Flutter untuk login/register, daftar user, ruang chat privat, realtime messaging, profil, dan dark mode.

> Status project: masih dalam tahap development/UTS, sehingga beberapa konfigurasi masih bersifat lokal atau hardcoded sesuai kode saat ini.

---

## Tech Stack

### Backend

- Go `1.25`
- Fiber `v2`
- Fiber WebSocket
- GORM + PostgreSQL
- JWT (`github.com/golang-jwt/jwt/v5`)
- Cloudinary untuk upload avatar
- Swagger UI (`swaggo/fiber-swagger`)
- Docker & Docker Compose

### Mobile

- Flutter SDK dengan Dart `>=3.11.0 <4.0.0`
- Dio untuk HTTP client
- `web_socket_channel` untuk koneksi WebSocket
- Provider + Flutter Bloc
- Shared Preferences / storage conditional web-IO
- Google Fonts, Lottie, Image Picker

---

## Struktur Project

```text
ws-chat-uts/
├── backend-go/
│   ├── config/          # Konfigurasi environment, database, Cloudinary
│   ├── docs/            # File Swagger hasil generate
│   ├── handlers/        # Handler REST API dan WebSocket
│   ├── middleware/      # Middleware JWT HTTP, JWT WebSocket, cache header
│   ├── model/           # Model GORM dan DTO request/response
│   ├── repository/      # Query database / data access layer
│   ├── routers/         # Registrasi route REST dan WebSocket
│   ├── Dockerfile
│   ├── go.mod
│   └── main.go
├── mobile_flutter/
│   ├── lib/
│   │   ├── controllers/     # Controller login, register, chat, message
│   │   ├── domain/          # Abstraksi repository Flutter
│   │   ├── model/           # Model data Flutter
│   │   ├── presentation/    # Halaman dan widget UI
│   │   ├── services/        # API client, WebSocket, profile, message service
│   │   ├── theme/           # Light/dark theme
│   │   ├── injection.dart   # Dependency injection get_it
│   │   └── main.dart
│   ├── test/
│   └── pubspec.yaml
├── docker-compose.yml
└── README.md
```

---

## Konfigurasi Environment Backend

Backend membaca environment dari file `.env` saat dijalankan lokal, atau dari environment container saat dijalankan via Docker Compose.

Buat file `.env` di root repository:

```env
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=chat_db
DB_HOST=db
DB_PORT=5432
APP_PORT=8080
JWT_ACCESS_SECRET=change-me-access-secret
JWT_REFRESH_SECRET=change-me-refresh-secret
CLOUDINARY_URL=cloudinary://<api_key>:<api_secret>@<cloud_name>
```

Catatan:

- Saat backend dijalankan dengan `docker compose`, `DB_HOST` otomatis diarahkan ke service `db` dan `DB_PORT` ke `5432` oleh `docker-compose.yml`.
- `CLOUDINARY_URL` wajib ada karena backend memanggil inisialisasi Cloudinary saat startup.
- Token access dibuat saat login dan dipakai untuk endpoint yang dilindungi serta koneksi WebSocket.

---

## Menjalankan Backend dengan Docker Compose

Prasyarat:

- Docker
- Docker Compose
- File `.env` di root repository

Jalankan:

```bash
docker compose up --build
```

Service yang dibuat oleh Compose saat ini:

| Service | Container | Port host | Keterangan |
| --- | --- | --- | --- |
| `db` | `chat-db` | `5432` | PostgreSQL 16 Alpine |
| `backend` | `chat-backend` | `8080` | Backend Go Fiber |

Cek status container:

```bash
docker compose ps
```

Backend akan tersedia di:

```text
http://localhost:8080
```

Root path `/` akan redirect ke Swagger UI:

```text
http://localhost:8080/swagger/index.html
```

---

## Menjalankan Backend secara Lokal tanpa Docker

Jika PostgreSQL sudah berjalan secara lokal, sesuaikan `.env` seperti contoh berikut:

```env
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=chat_db
DB_HOST=localhost
DB_PORT=5432
APP_PORT=8080
JWT_ACCESS_SECRET=change-me-access-secret
JWT_REFRESH_SECRET=change-me-refresh-secret
CLOUDINARY_URL=cloudinary://<api_key>:<api_secret>@<cloud_name>
```

Kemudian jalankan:

```bash
cd backend-go
go mod download
go run .
```

Saat startup, backend akan menjalankan `AutoMigrate` untuk tabel:

- `users`
- `profiles`
- `chat_rooms`
- `chat_members`
- `messages`
- `message_reads`

---

## Menjalankan Aplikasi Flutter

Prasyarat:

- Flutter SDK yang kompatibel dengan Dart `>=3.11.0 <4.0.0`
- Emulator/device/browser target Flutter

Jalankan:

```bash
cd mobile_flutter
flutter pub get
flutter run
```

Catatan penting:

- Base URL API mobile saat ini masih hardcoded di `mobile_flutter/lib/services/api_client_services.dart` menjadi `http://13.212.39.206:8080`.
- Untuk memakai backend lokal, ubah nilai `baseUrl` tersebut ke `http://localhost:8080` untuk web/desktop, atau alamat host yang dapat diakses emulator/device.
- WebSocket Flutter otomatis mengubah `http://` menjadi `ws://` dan `https://` menjadi `wss://` dari base URL yang sama.

---

## Fitur Backend Saat Ini

- Register user dengan email, username, dan password minimal 8 karakter.
- Login user dan penerbitan access token + refresh token.
- Refresh token melalui cookie `refresh_token`.
- Middleware JWT untuk endpoint HTTP protected.
- Middleware JWT untuk WebSocket melalui header `Authorization: Bearer <token>` atau query `?token=<token>`.
- Profile user: lihat profil, update profil, update profil berdasarkan user ID, dan upload avatar ke Cloudinary.
- User listing selain user yang sedang login.
- Membuat atau mengambil private chat room.
- Mengambil semua message atau message berdasarkan room.
- WebSocket room dengan action `join`, `leave`, dan `message`.
- Broadcast message ke semua koneksi yang terdaftar pada room yang sama.

---

## Fitur Flutter Saat Ini

- Splash screen dan routing awal berdasarkan token tersimpan.
- Login dan register.
- Penyimpanan token access/refresh di storage lokal.
- Daftar user untuk memulai chat privat.
- Membuat/mengambil room chat privat lewat REST API.
- Mengambil riwayat message berdasarkan room.
- Koneksi WebSocket untuk join room, leave room, dan kirim message realtime.
- Halaman settings untuk melihat/mengubah profil.
- Toggle dark mode.
- Dependency injection dengan `get_it` untuk service dan repository.

---

## REST API Endpoints

Base URL lokal backend:

```text
http://localhost:8080
```

Base path REST API:

```text
/api
```

Endpoint dengan tanda **Protected** wajib menyertakan header:

```http
Authorization: Bearer <access_token>
```

### Root dan Swagger

| Method | Path | Auth | Keterangan |
| --- | --- | --- | --- |
| `GET` | `/` | Tidak | Redirect ke `/swagger/index.html` |
| `GET` | `/swagger/*` | Tidak | Swagger UI |

### Auth

| Method | Path | Auth | Body | Keterangan |
| --- | --- | --- | --- | --- |
| `POST` | `/api/auth/register` | Tidak | `{ "username": "arya", "email": "arya@example.com", "password": "password123" }` | Membuat user dan profile |
| `POST` | `/api/auth/login` | Tidak | `{ "email": "arya@example.com", "password": "password123" }` | Menghasilkan `access_token`, `refresh_token`, `session_id`, dan `user_id` |
| `POST` | `/api/auth/refresh` | Cookie refresh | Tidak wajib | Menghasilkan access token baru dari cookie `refresh_token` |

### Profile

| Method | Path | Auth | Body | Keterangan |
| --- | --- | --- | --- | --- |
| `GET` | `/api/profile/me` | Protected | - | Mengambil profil user login |
| `PATCH` | `/api/profile/me` | Protected | `{ "username": "arya", "bio": "hello", "avatar": "https://..." }` | Update profil user login |
| `PATCH` | `/api/profile/update/:id` | Protected | `{ "username": "arya", "bio": "hello", "avatar": "https://..." }` | Update profil berdasarkan user UUID |
| `PATCH` | `/api/profile/avatar` | Protected | Multipart form field `avatar` | Upload avatar `.jpg`, `.jpeg`, atau `.png` ke Cloudinary |

### Users

| Method | Path | Auth | Keterangan |
| --- | --- | --- | --- |
| `GET` | `/api/users/` | Protected | Mengambil daftar user selain user login |
| `GET` | `/api/users/:id` | Protected | Mengambil detail user berdasarkan UUID |

### Chat Room

| Method | Path | Auth | Body | Keterangan |
| --- | --- | --- | --- | --- |
| `POST` | `/api/chat/private` | Protected | `{ "target_user_id": "<uuid>" }` | Mengambil room privat yang sudah ada atau membuat room baru |

### Messages

| Method | Path | Auth | Keterangan |
| --- | --- | --- | --- |
| `GET` | `/api/messages/` | Protected | Mengambil semua message |
| `GET` | `/api/messages/:room_id` | Protected | Mengambil message berdasarkan room UUID |

---

## WebSocket

Endpoint WebSocket:

```text
ws://localhost:8080/ws
```

Autentikasi dapat memakai salah satu cara berikut:

```http
Authorization: Bearer <access_token>
```

atau query parameter:

```text
ws://localhost:8080/ws?token=<access_token>
```

### Event Client ke Server

Join room:

```json
{
  "action": "join",
  "room_id": "<room_uuid>"
}
```

Leave room:

```json
{
  "action": "leave",
  "room_id": "<room_uuid>"
}
```

Kirim message:

```json
{
  "action": "message",
  "room_id": "<room_uuid>",
  "content": "Halo!",
  "type": "text"
}
```

### Event Server ke Client

Saat message berhasil disimpan, server broadcast payload seperti berikut ke room terkait:

```json
{
  "id": "<message_uuid>",
  "room_id": "<room_uuid>",
  "sender_id": "<user_uuid>",
  "content": "Halo!",
  "type": "text",
  "created_at": "2026-06-12T00:00:00Z"
}
```

Catatan: client harus melakukan `join` ke room sebelum mengirim `message`; jika belum join, message ditolak oleh handler WebSocket.

---

## Contoh Alur Penggunaan API

1. Register user A dan user B melalui `/api/auth/register`.
2. Login user A melalui `/api/auth/login` dan simpan `access_token`.
3. Ambil daftar user melalui `/api/users/` untuk mendapatkan target user.
4. Buat atau ambil room privat melalui `/api/chat/private` dengan `target_user_id`.
5. Buka koneksi WebSocket ke `/ws` menggunakan access token.
6. Kirim event `join` dengan `room_id`.
7. Kirim event `message` untuk chat realtime.
8. Ambil riwayat message melalui `/api/messages/:room_id` jika diperlukan.

---

## Testing dan Quality Check

Backend:

```bash
cd backend-go
go test ./...
```

Flutter:

```bash
cd mobile_flutter
flutter test
```

Analisis Flutter:

```bash
cd mobile_flutter
flutter analyze
```

---

## Database Diagram

Diagram database tersedia di draw.io:

- [Open Database Diagram](https://app.diagrams.net/?src=about#G1IQlvp4MQX225xthIo7t2NS_L4aQSXnYF#%7B%22pageId%22%3A%22kfpf0aNp-GbPhx4jT6oY%22%7D)

---

## Catatan Development

- `docker-compose.yml` saat ini hanya menjalankan PostgreSQL dan backend; Redis tidak digunakan pada kode/compose saat ini.
- Backend memakai GORM AutoMigrate, jadi tidak ada folder migration SQL khusus pada repository saat ini.
- Refresh token disimpan sebagai HTTP-only cookie saat login, sedangkan Flutter juga menyimpan `refresh_token` dari response JSON.
- Endpoint refresh saat ini menandatangani access token baru dengan secret refresh token sesuai implementasi kode saat ini.
- Beberapa nama file masih mengikuti kondisi project saat ini, misalnya `profle_handler.go`.

---

## Lisensi

Belum ada lisensi yang ditentukan di repository ini. Tambahkan file `LICENSE` jika project akan dipublikasikan atau dibagikan secara resmi.

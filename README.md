# 💬 Chat App

A real-time chat application built with **Spring Boot** and **Flutter Web**, featuring JWT authentication, WebSocket messaging, read receipts, and a modern UI inspired by WhatsApp.

![Status](https://img.shields.io/badge/status-active-success)
![Backend CI](https://github.com/ahmedshawky7/chat-app/actions/workflows/backend-ci.yml/badge.svg)
![Frontend CI](https://github.com/ahmedshawky7/chat-app/actions/workflows/frontend-ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 📖 Overview

Chat App is a full-stack real-time messaging platform where users can register, log in, and chat with each other instantly. It uses **WebSocket (STOMP)** for real-time communication, **JWT** for secure authentication, and **MySQL** for persistent storage.

---

## ✨ Features

### 🔐 Authentication
- User registration and login with JWT
- Access Token (15 min) + Refresh Token (7 days)
- Automatic token refresh on expiry (via Dio Interceptor)
- Secure password hashing with BCrypt

### 💬 Real-time Chat
- Instant message delivery via WebSocket (STOMP)
- Real-time read receipts (✓ / ✓✓)
- Unread message badges per conversation
- Auto-mark messages as read when opening a chat
- Persistent message history in MySQL

### 🎨 Modern UI
- WhatsApp-inspired chat bubbles with tails
- Color-coded user avatars (based on user ID)
- Date separators (Today / Yesterday / X days ago)
- Message timestamps
- Empty state for new conversations
- Auto-scroll to latest message
- Pull-to-refresh user list

### 🧪 Quality
- 8 Backend unit tests (JUnit + Mockito)
- H2 in-memory database for testing
- CI/CD pipeline with GitHub Actions
- Backend + Frontend CI passing

---

## 🛠️ Tech Stack

### Backend
| Tech | Version | Purpose |
|------|---------|---------|
| Java | 17 | Language |
| Spring Boot | 4.1.1 | Framework |
| Spring Security | Latest | Authentication |
| Spring Data JPA | Latest | ORM |
| Spring WebSocket | Latest | Real-time messaging |
| MySQL | 8.0 | Database |
| JWT (JJWT) | 0.12.6 | Token management |
| Lombok | Latest | Boilerplate reduction |
| Maven | Latest | Build tool |

### Frontend
| Tech | Version | Purpose |
|------|---------|---------|
| Flutter | 3.47.0 | Framework |
| Dart | 3.13.0 | Language |
| flutter_bloc | 9.1.1 | State management (Cubit) |
| Dio | 5.7.0 | HTTP client |
| stomp_dart_client | 2.0.0 | WebSocket client |
| shared_preferences | 2.3.2 | Local storage |
| equatable | 3.0.0 | Value equality |

### DevOps
- **GitHub Actions** — CI/CD (Backend + Frontend)
- **Docker** — Containerization
- **Docker Compose** — Multi-container orchestration

---

## 🏗️ Architecture

```
Flutter Web (Frontend)
        ↓ HTTPS + WSS
Spring Boot (Backend)
        ↓ JDBC
MySQL Database
```

### Design Patterns
- **Feature-based architecture** (Frontend)
- **Repository pattern** (Data layer)
- **Cubit/Bloc pattern** (State management)
- **DTO pattern** (Data transfer)
- **Service layer** (Business logic)
- **Filter chain** (Security)

---

## 📁 Project Structure

```
chat-app/
├── backend/                          # Spring Boot application
│   ├── src/main/java/com/example/chat/
│   │   ├── config/                   # Security & WebSocket config
│   │   ├── controller/               # REST & WebSocket controllers
│   │   ├── dto/                      # Data Transfer Objects
│   │   ├── entity/                   # JPA entities
│   │   ├── repository/               # JPA repositories
│   │   ├── security/                 # JWT + filters
│   │   └── service/                  # Business logic
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── src/test/                     # Unit tests
│   ├── Dockerfile
│   └── pom.xml
│
├── frontend/                         # Flutter Web application
│   ├── lib/
│   │   ├── core/                     # Shared utilities
│   │   └── features/                 # Feature modules
│   ├── Dockerfile
│   ├── nginx.conf
│   └── pubspec.yaml
│
├── .github/workflows/                # CI/CD pipelines
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- **Java 17+**
- **Maven 3.8+**
- **Flutter 3.13+**
- **MySQL 8.0+**
- **Docker & Docker Compose** (optional)

### Option 1: Docker (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ahmedshawky7/chat-app.git
   cd chat-app
   ```

2. **Create `.env` file:**
   ```bash
   cp .env.example .env
   ```

3. **Start all services:**
   ```bash
   docker-compose up --build
   ```

4. **Access the app:**
   - Backend API: `http://localhost:8080`
   - Frontend: `http://localhost`

### Option 2: Manual Setup

#### Backend

```bash
cd backend
./mvnw spring-boot:run
```

#### Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 🧪 Testing

### Backend

```bash
cd backend
./mvnw clean test
```

**Expected output:**
```
Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

### Frontend

```bash
cd frontend
flutter analyze
flutter test
```

---

## 📡 API Endpoints

### Authentication (`/api/auth`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/register` | Register new user | ❌ |
| POST | `/login` | Login user | ❌ |
| POST | `/refresh` | Refresh access token | ❌ |

### Chat (`/api/chat`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/send` | Send message (REST) | ✅ |
| GET | `/conversation/{userId}` | Get conversation | ✅ |
| POST | `/read/{userId}` | Mark as read | ✅ |
| GET | `/users` | Get all users | ✅ |
| GET | `/unread-counts` | Unread per sender | ✅ |
| GET | `/unread-total` | Total unread | ✅ |

### WebSocket

| Destination | Type | Description |
|-------------|------|-------------|
| `/app/chat.send` | Send | Send message via WebSocket |
| `/user/queue/messages` | Subscribe | Receive messages |
| `/user/queue/reads` | Subscribe | Receive read receipts |

---

## 🔐 Security

- **Passwords** hashed with BCrypt
- **JWT** for stateless authentication
- **Refresh Tokens** stored in DB (revocable)
- **CORS** configured for allowed origins
- **CSRF** disabled (JWT-based auth)
- **HTTPS/WSS** in production

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Ahmed Shawky**
- GitHub: [@ahmedshawky7](https://github.com/ahmedshawky7)

---

## 📊 Project Status

| Phase | Feature | Status |
|-------|---------|--------|
| 1 | Authentication (JWT) | ✅ Complete |
| 2 | Frontend Auth Screens | ✅ Complete |
| 3 | Real-time Chat (WebSocket) | ✅ Complete |
| 4 | Read/Unread State | ✅ Complete |
| 5A | UX Improvements | ✅ Complete |
| 5B | Read Receipts | ✅ Complete |
| 5C | Better UI | ✅ Complete |
| 5D | Notifications | ✅ Complete |
| 5E | JWT Refresh Tokens | ✅ Complete |
| 5F | Unit Tests | ✅ Complete |
| 6 | Deployment | 🚧 In Progress |
| 7 | Email Verification | 📋 Planned |
| 8 | Group Chats | 📋 Planned |
| 9 | Media Messages | 📋 Planned |

---

⭐ **If you like this project, give it a star!**

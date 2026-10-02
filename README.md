# NoBroker Owner Listings

A premium Flutter mobile application for direct owner-to-tenant/buyer property discovery.

## Features

- Direct property marketplace (no brokers)
- Owner verification system
- In-app audio/video calling via LiveKit
- Property search and filtering
- Saved properties and comparisons
- Inquiry management
- Rental agreement creation with e-signature
- PDF generation
- Movers and packers integration
- Premium listing support
- Rent and notice-period reminders
- Admin moderation

## Architecture

- **Frontend:** Flutter + Riverpod + GoRouter + Drift
- **Backend:** NestJS + Prisma + PostgreSQL (Neon)
- **Calling:** LiveKit Cloud
- **Auth:** JWT (access + refresh tokens)

## Project Structure

```
cross_platform/
├── frontend/          # Flutter mobile app
└── backend/           # NestJS API server
```

## Setup

### Backend
See `backend/README.md`

### Frontend

1. Navigate to frontend:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Create `.env` file with:
   ```
   API_BASE_URL=http://localhost:5001/api
   LIVEKIT_URL=wss://your-project.livekit.cloud
   ```

5. Run app:
   ```bash
   flutter run
   ```

## Environment Variables

### Backend (.env)
- DATABASE_URL
- JWT_ACCESS_SECRET
- JWT_REFRESH_SECRET
- LIVEKIT_URL
- LIVEKIT_API_KEY
- LIVEKIT_API_SECRET

### Flutter
- API_BASE_URL
- LIVEKIT_URL

**NEVER** put database credentials or API secrets in Flutter.

## Tech Stack

### Flutter
- flutter_riverpod
- go_router
- dio
- freezed + json_serializable
- drift + drift_flutter
- livekit_client
- flutter_secure_storage
- cached_network_image
- signature
- pdf + printing
- phosphor_flutter

### Backend
- @nestjs/*
- prisma + @prisma/client
- passport-jwt
- bcrypt
- livekit-server-sdk
- pdfkit
- class-validator
- helmet

## Development Notes

- No Firebase
- No push notifications in v1
- No OTP
- No social login
- No real payment gateway (mock simulation)
- No phone calling (internet calling only via LiveKit)

## License

MIT

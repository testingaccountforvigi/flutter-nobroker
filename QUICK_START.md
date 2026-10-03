# NoBroker Owner Listings - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Node.js 18+ installed
- Flutter 3.5.0+ installed
- A device/emulator for Flutter

---

## Backend Setup (2 minutes)

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# The database is already configured with Neon PostgreSQL
# Check .env file - DATABASE_URL should be set

# Generate Prisma client
npx prisma generate

# Database is already migrated and seeded!
# But if you need to reset:
# npx prisma migrate dev
# npx ts-node prisma/seed.ts

# Start the server
npm run start:dev
```

**✅ Backend running**: http://localhost:5001/api  
**✅ Swagger docs**: http://localhost:5001/api/docs

---

## Frontend Setup (2 minutes)

```bash
# Navigate to frontend
cd frontend

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

**✅ App running on your device!**

---

## Test the Application (1 minute)

### Login with Test Account
1. Open the app
2. Click "Login"
3. Enter credentials:
   - **Email**: `rajesh@example.com`
   - **Password**: `password123`

### Try These Features
✅ **Browse Properties** - Home screen shows 4 seeded properties  
✅ **View Details** - Tap any property card  
✅ **Add to Favorites** - Heart icon on property cards  
✅ **Owner Dashboard** - Menu → Owner Dashboard  
✅ **Create Property** - Dashboard → FAB button  
✅ **View Leads** - Dashboard → Leads tab  
✅ **Profile** - Menu → Profile

---

## Test Accounts

| Email | Password | Type | Use For |
|-------|----------|------|---------|
| rajesh@example.com | password123 | Owner | Property management, leads |
| priya@example.com | password123 | Seeker | Browse, inquire, favorites |
| admin@nobroker.com | password123 | Admin | Admin features (future) |

---

## Key Endpoints to Test

### Auth
```bash
# Register
POST http://localhost:5001/api/auth/register
{
  "email": "test@example.com",
  "password": "password123",
  "name": "Test User",
  "accountIntent": "SEEKER"
}

# Login
POST http://localhost:5001/api/auth/login
{
  "email": "rajesh@example.com",
  "password": "password123"
}
```

### Properties
```bash
# Get all properties
GET http://localhost:5001/api/properties

# Get property details
GET http://localhost:5001/api/properties/{id}

# Search with filters
GET http://localhost:5001/api/properties?city=Mumbai&purpose=RENT
```

### Favorites
```bash
# Get my favorites
GET http://localhost:5001/api/favorites
# Requires Authorization: Bearer {token}
```

---

## What's Working

✅ **Authentication** - Register, login, logout, token refresh  
✅ **Properties** - Browse, search, create, edit, photos  
✅ **Favorites** - Add, remove, list  
✅ **Inquiries** - Send inquiry, view leads, update status  
✅ **Dashboard** - Owner dashboard with analytics  
✅ **Profile** - View and edit profile

---

## Common Issues & Solutions

### Backend won't start
```bash
# Make sure DATABASE_URL is set in .env
# Check if port 5001 is available
lsof -ti:5001 | xargs kill -9  # Kill any process on port 5001
```

### Flutter build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Database issues
```bash
# Reset database
cd backend
npx prisma migrate reset  # This will drop and recreate everything
npx ts-node prisma/seed.ts
```

---

## Directory Structure

```
cross_platform/
├── backend/               # NestJS backend
│   ├── src/              # Source code
│   ├── prisma/           # Database schema & migrations
│   └── .env              # Environment variables
│
├── frontend/             # Flutter frontend
│   ├── lib/
│   │   ├── core/         # Reusable components
│   │   └── features/     # Feature modules
│   └── pubspec.yaml      # Dependencies
│
├── QUICK_START.md        # This file
└── README.md             # Main documentation
```

---

## Next Steps

1. ✅ **Test Core Features** - Use the test accounts
2. ✅ **Explore API** - Check Swagger docs
3. ✅ **Browse Code** - Check the architecture
4. 📱 **Build APK** - `flutter build apk --release`
5. 🚀 **Deploy** - Set up production environment

---

## Need Help?

- **Backend Logs**: Check terminal where you ran `npm run start:dev`
- **Frontend Logs**: Check terminal where you ran `flutter run`
- **Database**: Open Prisma Studio with `npx prisma studio`
- **API Docs**: Visit http://localhost:5001/api/docs

---

## Status

✅ **Backend**: Running on port 5001  
✅ **Frontend**: Compiles with 0 errors  
✅ **Database**: Migrated with test data  
✅ **Features**: Core MVP complete

**Enjoy exploring the application!** 🎉

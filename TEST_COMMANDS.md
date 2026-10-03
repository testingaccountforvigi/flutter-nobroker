# Test Commands - NoBroker Application

## Quick Health Check

### Backend Health
```bash
cd backend
npm run start:dev &
sleep 5
curl http://localhost:5001/api/health
# Expected: {"status":"ok"}
```

### Frontend Health
```bash
cd frontend
flutter analyze
# Expected: "No issues found!"
```

---

## API Testing with cURL

### 1. Register a New User
```bash
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@test.com",
    "password": "password123",
    "name": "New User",
    "accountIntent": "SEEKER"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "rajesh@example.com",
    "password": "password123"
  }'
  
# Save the accessToken from response for next requests
```

### 3. Get Properties
```bash
curl http://localhost:5001/api/properties
```

### 4. Get Property Details
```bash
# Replace {propertyId} with an actual ID from previous response
curl http://localhost:5001/api/properties/{propertyId}
```

### 5. Get My Profile (Authenticated)
```bash
# Replace {YOUR_TOKEN} with the accessToken from login
curl http://localhost:5001/api/auth/me \
  -H "Authorization: Bearer {YOUR_TOKEN}"
```

### 6. Get My Favorites (Authenticated)
```bash
curl http://localhost:5001/api/favorites \
  -H "Authorization: Bearer {YOUR_TOKEN}"
```

### 7. Add to Favorites
```bash
curl -X POST http://localhost:5001/api/favorites \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -d '{
    "propertyId": "{PROPERTY_ID}"
  }'
```

### 8. Get Amenities
```bash
curl http://localhost:5001/api/amenities
```

---

## Flutter Testing Commands

### Run Analyzer
```bash
cd frontend
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Build APK (Debug)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Build APK (Release)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Run on Specific Device
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d {device-id}
```

---

## Backend Testing

### Run Compilation Check
```bash
cd backend
npm run build
```

### Start Development Server
```bash
npm run start:dev
```

### View Database
```bash
npx prisma studio
# Opens at http://localhost:5555
```

### Reset Database
```bash
npx prisma migrate reset
npx ts-node prisma/seed.ts
```

### Generate Prisma Client
```bash
npx prisma generate
```

---

## Integration Testing Flow

### Complete User Journey Test

1. **Start Backend**
```bash
cd backend
npm run start:dev
```

2. **Register New User**
```bash
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "password123",
    "name": "Test User",
    "accountIntent": "SEEKER"
  }'
```

3. **Login**
```bash
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "password123"
  }' | jq '.accessToken'
  
# Save the token
export TOKEN="your_access_token_here"
```

4. **Get Properties**
```bash
curl http://localhost:5001/api/properties | jq '.properties[0].id'

# Save first property ID
export PROPERTY_ID="property_id_here"
```

5. **Get Property Details**
```bash
curl http://localhost:5001/api/properties/$PROPERTY_ID | jq
```

6. **Add to Favorites**
```bash
curl -X POST http://localhost:5001/api/favorites \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"propertyId\": \"$PROPERTY_ID\"}"
```

7. **Get My Favorites**
```bash
curl http://localhost:5001/api/favorites \
  -H "Authorization: Bearer $TOKEN" | jq
```

8. **Create Inquiry**
```bash
curl -X POST http://localhost:5001/api/inquiries \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"propertyId\": \"$PROPERTY_ID\",
    \"message\": \"I am interested in this property. Please contact me.\"
  }"
```

9. **Get My Inquiries**
```bash
curl http://localhost:5001/api/inquiries/my-inquiries \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## Performance Testing

### Load Test with Apache Bench (if installed)
```bash
# Test property listing endpoint
ab -n 1000 -c 10 http://localhost:5001/api/properties
```

### Simple Load Test with cURL
```bash
# Run 100 requests
for i in {1..100}; do
  curl -s http://localhost:5001/api/properties > /dev/null &
done
wait
echo "Load test complete"
```

---

## Database Queries

### Check User Count
```bash
cd backend
npx prisma studio
# Or use direct SQL:
# psql $DATABASE_URL -c "SELECT COUNT(*) FROM \"User\";"
```

### Check Property Count
```bash
# In Prisma Studio or:
# psql $DATABASE_URL -c "SELECT COUNT(*) FROM \"Property\";"
```

---

## Swagger Testing

1. Start backend: `npm run start:dev`
2. Open browser: http://localhost:5001/api/docs
3. Click "Authorize" button
4. Login via `/auth/login` endpoint
5. Copy the `accessToken`
6. Paste in authorization (format: `Bearer {token}`)
7. Test all authenticated endpoints

---

## Flutter UI Testing Checklist

### Authentication Flow
- [ ] Open app
- [ ] Navigate to Register
- [ ] Fill form and submit
- [ ] Verify redirect to Home
- [ ] Logout
- [ ] Login with credentials
- [ ] Verify redirect to Home

### Property Browsing
- [ ] See property list on Home
- [ ] Scroll through properties
- [ ] Pull to refresh
- [ ] Tap property card
- [ ] View property details
- [ ] Scroll through images
- [ ] View all amenities
- [ ] Tap back

### Favorites
- [ ] Add property to favorites (heart icon)
- [ ] Go to Favorites screen (menu)
- [ ] See favorited property
- [ ] Remove from favorites
- [ ] Verify removed

### Inquiries
- [ ] Open property details
- [ ] Tap "Contact Owner"
- [ ] Send inquiry
- [ ] Go to My Inquiries (menu)
- [ ] See inquiry listed

### Owner Dashboard (Login as Owner)
- [ ] Login as rajesh@example.com
- [ ] Open Owner Dashboard (menu)
- [ ] Check Overview stats
- [ ] Switch to Properties tab
- [ ] See owned properties
- [ ] Tap Pause on a property
- [ ] Switch to Leads tab
- [ ] See received inquiries
- [ ] Update lead status

### Profile
- [ ] Open Profile (menu)
- [ ] Edit name
- [ ] Save changes
- [ ] Verify updated
- [ ] Logout

---

## Common Test Scenarios

### Scenario 1: New Seeker Flow
1. Register as SEEKER
2. Browse properties
3. Add 2 properties to favorites
4. Send inquiry on 1 property
5. Check My Inquiries
✅ **Expected**: All operations succeed, data persists

### Scenario 2: New Owner Flow
1. Register as OWNER
2. Go to Owner Dashboard
3. Create new property (all 5 steps)
4. Upload 3 photos
5. Publish property
6. See property in Properties tab
✅ **Expected**: Property created and visible

### Scenario 3: Lead Management
1. Login as Owner (rajesh@example.com)
2. Go to Dashboard → Leads tab
3. See existing leads
4. Update lead status to "CONTACTED"
5. Refresh
✅ **Expected**: Status updated and persists

---

## Debugging Commands

### View Backend Logs
```bash
cd backend
npm run start:dev
# Logs appear in terminal
```

### View Flutter Logs
```bash
cd frontend
flutter run
# Logs appear in terminal
# Or use: flutter logs
```

### Check Database State
```bash
cd backend
npx prisma studio
# Browse all tables visually
```

### Clear Flutter Build Cache
```bash
cd frontend
flutter clean
flutter pub get
```

---

## Expected Results Summary

✅ **Backend Endpoints**: All auth, properties, favorites, inquiries endpoints work  
✅ **Flutter Build**: Compiles with 0 errors, 0 warnings  
✅ **Authentication**: Register, login, logout, token refresh all work  
✅ **CRUD Operations**: Create, read, update, delete work for properties  
✅ **Data Persistence**: All data saved to PostgreSQL  
✅ **UI Navigation**: All screens accessible and functional  

---

## Quick Smoke Test (2 minutes)

```bash
# Terminal 1: Start backend
cd backend && npm run start:dev

# Terminal 2: Test health
curl http://localhost:5001/api/health

# Terminal 3: Test properties
curl http://localhost:5001/api/properties

# Terminal 4: Start Flutter
cd frontend && flutter run

# In the app:
# 1. Login with rajesh@example.com / password123
# 2. Browse properties
# 3. Open one property
# 4. Go to Owner Dashboard
# 5. Check all tabs

# ✅ If all above work, core system is functioning!
```

---

## Report Issues

If something doesn't work:
1. Check backend is running on port 5001
2. Check DATABASE_URL in backend/.env
3. Verify Prisma client is generated: `npx prisma generate`
4. Check Flutter dependencies: `flutter pub get`
5. View error logs in terminal

**Status**: Ready for testing! 🚀

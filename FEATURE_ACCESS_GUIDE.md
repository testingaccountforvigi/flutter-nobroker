# Feature Access Guide - NoBroker App

## 🔐 Login First

Before accessing features, login with test credentials:

```
Owner Account:
Email: rajesh@example.com
Password: password123

Seeker Account:
Email: priya@example.com
Password: password123

Admin Account:
Email: admin@nobroker.com
Password: password123
```

---

## 📱 How to Access Each Feature

### 1. **Calling Feature (LiveKit Audio Calls)**

**For Owner (Receives Calls)**:
1. Login as owner (rajesh@example.com)
2. App automatically connects to call socket
3. When someone calls, you'll see instant pop-up dialog
4. Options: "Accept" or "Decline"
5. If accepted → CallScreen opens with mute/speaker/end controls

**For Seeker (Makes Calls)**:
1. Login as seeker (priya@example.com)
2. Browse properties on home screen
3. Tap any property to open details
4. Scroll down, tap **"Contact Owner"** button
5. Dialog shows 2 options:
   - **"Send Email"** - Opens mailto: link
   - **"Call Now"** - Instantly initiates LiveKit call
6. Tap "Call Now"
7. Owner receives instant notification
8. Call connects when owner accepts

**Troubleshooting Calls**:
- Both users must be logged in simultaneously
- Backend must be running on port 5001
- Check browser console for WebSocket connection logs
- If not working:
  ```bash
  # Backend logs
  cd backend && npm run start:dev
  
  # Check for: "Connected to call socket"
  ```

---

### 2. **Rental Agreement Generator**

**Access Method**:
Currently backend is ready, frontend screen pending.

**Manual API Access** (Until frontend is ready):
```bash
# Create Agreement
curl -X POST http://localhost:5001/api/agreements/generate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "propertyId": "property-uuid",
    "tenantId": "tenant-uuid",
    "rent": 25000,
    "deposit": 50000,
    "startDate": "2024-12-01",
    "endDate": "2025-11-30",
    "noticePeriodDays": 30
  }'

# Sign Agreement
curl -X POST http://localhost:5001/api/agreements/{id}/sign \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "signatureData": "base64-encoded-signature"
  }'

# Download PDF
curl -X GET http://localhost:5001/api/agreements/{id}/pdf \
  -H "Authorization: Bearer YOUR_TOKEN" \
  --output agreement.pdf
```

**Price**: ₹199 per agreement

---

### 3. **Premium Listing Upgrade**

**Access Method**:
1. Login as property owner (rajesh@example.com)
2. Tap profile icon (top right)
3. Select **"Owner Dashboard"**
4. You'll see 3 tabs: Active, Inactive, Leads
5. Tap on any property card
6. Look for **"Upgrade to Premium"** button
7. Tap to see pricing plans

**Pricing Plans**:
- **Basic**: ₹499/30 days
- **Standard**: ₹1,299/90 days (Save ₹198) - RECOMMENDED
- **Premium Plus**: ₹2,399/180 days (Save ₹582)

**Benefits**:
- Top of search results
- Premium badge
- 3-10x more visibility
- Priority support

**Alternative Access**:
You can also navigate directly by creating this file:

`lib/features/premium/presentation/screens/premium_screen_access.dart`:
```dart
// Add this to ProfileScreen as a menu item
ListTile(
  leading: Icon(Icons.star, color: Colors.amber),
  title: Text('Premium Upgrade'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PremiumUpgradeScreen(
          propertyId: 'your-property-id',
          propertyTitle: 'Your Property Title',
        ),
      ),
    );
  },
)
```

---

### 4. **Favorites**

**Access Method**:
1. Login as any user
2. Tap on any property to view details
3. Scroll to bottom
4. Look for **heart icon button** next to "Contact Owner"
5. Tap heart icon to add/remove favorite
6. Icon fills red when favorited

**View All Favorites**:
1. Tap profile icon (top right)
2. Select **"Favorites"**
3. See all saved properties

**How It Works**:
- Empty heart ♡ = Not favorited
- Filled heart ♥ = Favorited (red color)
- Real-time sync with backend
- Persists across sessions

---

### 5. **Owner Verification**

**Access Method**:
1. Login as property owner
2. Tap profile icon → **"Profile"**
3. Look for verification section
4. Scroll to **"Verification"** menu item
5. Tap to open VerificationScreen
6. Upload government ID (Aadhaar, PAN, DL, Passport)
7. Select document type
8. Submit for admin review

**Admin Approval**:
1. Login as admin (admin@nobroker.com)
2. Tap profile icon → **"Profile"**
3. Tap **"Admin Dashboard"** (admin only)
4. Go to **"Verifications"** tab
5. Review pending requests
6. Approve or Reject with notes

---

### 6. **Property Photos with Image URL**

**Access Method**:
1. Login as owner
2. Tap profile icon → **"Owner Dashboard"**
3. Tap **"+ Add Property"** button
4. Fill steps 1-3 (Basic Info, Details, Location)
5. On **Step 4: Photos**:
   - **Option 1**: Tap "Add Photos" to pick from device
   - **Option 2**: Paste image URL in text field
     - Example: `https://example.com/property.jpg`
     - Must start with http:// or https://
     - Tap "+" button or press Enter
6. Continue to Amenities and Submit

**Supported URLs**:
- Google Drive (public links)
- Imgur
- Any public image hosting
- Direct image URLs (.jpg, .png, .jpeg)

---

### 7. **Movers & Packers**

**Access Method**:
1. Login as any user
2. Tap profile icon → **"Profile"**
3. Scroll down to **"Features"** section
4. Tap **"Movers & Packers"**
5. Two tabs available:
   - **My Requests**: Your moving requests
   - **Browse Quotes**: Compare mover quotes

**Request Quote**:
1. Tap **"New Request"** or **"+"**
2. Fill form:
   - From Address
   - To Address
   - Moving Date
   - Inventory (items list)
   - Special notes
3. Submit request
4. Receive multiple free quotes
5. Compare prices and ratings
6. Accept best quote

**Price**: FREE quotes, pay on service completion

---

### 8. **Reminders**

**Access Method**:
1. Login as any user
2. Tap profile icon → **"Profile"**
3. Scroll to **"Features"** section
4. Tap **"Reminders"**
5. See all upcoming reminders

**Add Reminder**:
1. Tap **"+"** button (floating action button)
2. Fill form:
   - Title (e.g., "Rent Due")
   - Description
   - Due Date (calendar picker)
   - Type (RENT_DUE, NOTICE_PERIOD, MAINTENANCE, etc.)
3. Save reminder

**Types Available**:
- **Rent Due**: Monthly rent payments
- **Notice Period**: Tenancy ending
- **Maintenance**: Property maintenance
- **Inspection**: Property inspection
- **Document**: Document submission
- **Other**: Custom reminders

---

### 9. **Admin Dashboard**

**Access Method** (Admin only):
1. Login as admin (admin@nobroker.com)
2. Tap profile icon → **"Profile"**
3. Scroll to **"Admin Panel"** (only visible to admin)
4. Tap to open AdminDashboardScreen

**4 Tabs Available**:
- **Overview**: Statistics (users, properties, inquiries)
- **Users**: Manage all users
- **Properties**: Manage all properties
- **Verifications**: Approve/reject owner verifications

---

### 10. **Notifications**

**Access Method**:
1. Login as any user
2. Tap profile icon → **"Profile"**
3. Tap **"Notifications"**
4. See all notifications

**Notification Types**:
- New inquiry on your property
- Call missed/received
- Agreement signed
- Mover quote received
- Verification approved/rejected

---

## 🔧 Troubleshooting

### Calling Not Working?

**Check these**:
1. Both users logged in?
2. Backend running? `cd backend && npm run start:dev`
3. Frontend running? `cd frontend && flutter run -d chrome`
4. Check browser console for:
   ```
   CallManager: Initializing for user <id>
   CallManager: Socket connection initiated
   CallManager: Incoming call received from <name>
   ```

**If owner not receiving calls**:
1. Logout and login again (reinitializes socket)
2. Check backend logs for WebSocket connection
3. Verify user ID in socket registration

### Favorites Not Working?

1. Check if logged in (JWT token present)
2. Backend running on port 5001?
3. Heart icon should change color immediately
4. Check browser console for errors

### Premium Page Not Found?

Currently accessed via Owner Dashboard → Property → Upgrade button
Or create direct navigation as shown in section 3 above

### Image URL Not Working?

1. Ensure URL starts with http:// or https://
2. URL must be publicly accessible
3. Try the URL in browser first
4. For Google Drive: Use direct link, not sharing link

---

## 🎯 Quick Feature Test Checklist

```
✅ Login (rajesh@example.com / priya@example.com)
✅ Browse properties on home
✅ View property details
✅ Favorite a property (heart icon)
✅ Contact Owner → Call Now
✅ Accept call (other user)
✅ Add property with image URL
✅ Upgrade to Premium (₹499)
✅ Request mover quotes
✅ Add rent reminder
✅ Submit verification docs
✅ Admin: Approve verification
```

---

## 📞 Support

If features aren't working:

1. **Check backend is running**:
   ```bash
   cd backend
   npm run start:dev
   # Should see: Application is running on: http://localhost:5001/api
   ```

2. **Check frontend is running**:
   ```bash
   cd frontend
   flutter run -d chrome
   ```

3. **Check API documentation**:
   Open: `http://localhost:5001/api/docs`

4. **Check browser console**:
   Press F12 → Console tab → Look for errors

5. **Test API directly**:
   Use Swagger UI at `/api/docs` to test endpoints

---

**Last Updated**: November 2024
**App Version**: 1.0.0

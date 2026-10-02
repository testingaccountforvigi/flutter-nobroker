# Database Setup Guide

## Prerequisites
- Neon PostgreSQL database created
- `.env` file configured with DATABASE_URL

## Step 1: Create Initial Migration

Run this command to create the database schema:

```bash
cd backend
npx prisma migrate dev --name init
```

This will:
- Create all 24 tables in your Neon database
- Generate the Prisma client
- Apply all relationships and indexes

## Step 2: Verify Database

Check that tables were created:

```bash
npx prisma studio
```

This opens a web interface at http://localhost:5555 where you can view all tables.

## Step 3: Seed Database (Optional - will be done in PHASE 18)

After migration, you can seed test data:

```bash
npm run prisma:seed
```

## Troubleshooting

### If migration fails:
```bash
# Reset and try again
npx prisma migrate reset
npx prisma migrate dev --name init
```

### Check connection:
```bash
npx prisma db push
```

### Generate client only:
```bash
npx prisma generate
```

## Tables That Will Be Created:

1. User - User accounts with roles
2. RefreshToken - JWT refresh tokens
3. Property - Property listings
4. PropertyPhoto - Property images
5. FloorPlan - Floor plan images
6. Amenity - Amenity master list
7. PropertyAmenity - Property-amenity relationships
8. Favorite - Saved properties
9. PropertyView - Property view tracking
10. Inquiry - Property inquiries
11. VisitRequest - Visit scheduling
12. Call - LiveKit call records
13. VerificationRequest - Owner verification
14. Agreement - Rental agreements
15. AgreementSignature - Digital signatures
16. Mover - Mover companies
17. MovingRequest - Moving service requests
18. MovingItem - Items to move
19. MoverQuote - Quotes from movers
20. MoverBooking - Confirmed bookings
21. Reminder - User reminders
22. PremiumOrder - Premium listing orders
23. Report - User reports
24. InAppNotification - In-app notifications
25. AuditLog - Admin audit trail

All tables include proper indexes, relationships, and constraints as defined in the Prisma schema.

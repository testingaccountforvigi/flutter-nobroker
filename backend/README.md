# NoBroker Backend API

NestJS backend for NoBroker Owner Listings platform.

## Setup

1. Copy `.env.example` to `.env` and configure:
   - DATABASE_URL (Neon PostgreSQL)
   - JWT secrets
   - LiveKit credentials

2. Install dependencies:
   ```bash
   npm install
   ```

3. Generate Prisma client:
   ```bash
   npm run prisma:generate
   ```

4. Run migrations:
   ```bash
   npm run prisma:migrate
   ```

5. Seed database:
   ```bash
   npm run prisma:seed
   ```

## Development

```bash
npm run start:dev
```

## Build

```bash
npm run build
```

## Test

```bash
npm test
```

## API Documentation

Swagger UI available at: http://localhost:5001/api/docs

# Sami-shope Backend

Medusa 2.19 backend for Sami-shope.

## Stack

- Medusa 2.19
- Node.js 22.12+
- PostgreSQL 17
- Redis 7

## Local setup

```bash
cp .env.template .env
docker compose -f compose.yml up -d
npm install
npm run db:setup
npm run dev
```

Medusa Admin is served by the backend and the Store API is consumed by the Flutter app in `../frontend`.

## Frontend connection

Run Flutter with the backend URL and Medusa publishable key:

```bash
flutter run \
  --dart-define=MEDUSA_BASE_URL=http://localhost:9000 \
  --dart-define=MEDUSA_PUBLISHABLE_KEY=pk_your_key
```

## Environment

Never commit `.env`. Use `.env.template` only as a reference and replace `JWT_SECRET` and `COOKIE_SECRET` with long random values in real environments.

## Architecture rule

Do not modify Medusa core packages. Sami-shope custom behavior belongs under this backend's `src/` using Medusa modules, workflows, API routes, subscribers, and admin extensions.

## Current milestone

This stage establishes a clean, buildable Medusa base only. Multi-store, merchant scoping, cart customization, checkout, and realtime are added in later feature branches after the base is verified.

## Upstream

See `UPSTREAM.md` for the official Medusa starter source used to bootstrap this backend.

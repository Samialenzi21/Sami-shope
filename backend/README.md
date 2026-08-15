# Sami Shope Backend

Standalone Medusa v2.19 backend for the Flutter storefront in `../frontend`.

## Stack

- Medusa 2.19
- Node.js 22 LTS
- PostgreSQL
- TypeScript

## Local setup

```bash
cp .env.template .env
npm install
npm run db:migrate
npm run dev
```

The Admin dashboard is served by Medusa. The public backend status endpoint is:

```text
GET /status
```

The Flutter catalog uses Medusa's Store API:

```text
GET /store/products
```

Store API requests that require a publishable API key must send the key configured for the deployed Medusa instance. Flutter receives the backend URL and publishable key through `--dart-define`; secrets must not be committed to this repository.

## Architecture rules

- Backend code stays inside `backend/`.
- Flutter code stays inside `frontend/`.
- Do not modify Medusa core.
- Project behavior belongs in Medusa modules, workflows, subscribers, links, API routes, and other supported extension points.
- Build the single-store order flow first; multi-store scoping and realtime are added after the base flow is verified.

See `UPSTREAM.md` for the official starter source used to bootstrap this directory.

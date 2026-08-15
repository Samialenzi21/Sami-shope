# Sami Shope Backend

Standalone Medusa v2.19 backend for the Flutter storefront in `../frontend`.

## Stack

- Medusa 2.19
- Node.js 22 LTS
- pnpm 10.11.1
- PostgreSQL
- TypeScript

## Local setup

```bash
cp .env.template .env
corepack enable
corepack prepare pnpm@10.11.1 --activate
pnpm install --frozen-lockfile
pnpm db:migrate
pnpm bootstrap:saudi
pnpm dev
```

For local PostgreSQL, `docker-compose.yml` provides a `postgres:16-alpine` service matching the default `.env.template` database URL.

## Saudi commerce bootstrap

Run this once after migrations on a new environment:

```bash
pnpm bootstrap:saudi
```

It creates the production foundation without demo products:

- `Sami Shope` store with SAR as the default currency.
- Saudi Arabia region (`sa`).
- Storefront sales channel.
- Publishable API key for Flutter.
- Riyadh stock location.
- Saudi tax region.
- Manual system payment provider for the region.
- Pickup fulfillment set and a free `Store Pickup` option.

The command prints the publishable API key. Supply that public key to Flutter as `MEDUSA_PUBLISHABLE_KEY`; do not hard-code environment-specific values in the app source.

The bootstrap is safe to run again after a completed run: it detects the existing `Sami Shope` store and exits without creating duplicates.

To validate an environment:

```bash
pnpm verify:saudi
```

## APIs

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
- Do not seed fake/demo catalog data into production environments.
- Project behavior belongs in Medusa modules, workflows, subscribers, links, API routes, and other supported extension points.
- Build the single-store order flow first; multi-store scoping and realtime are added after the base flow is verified.

See `UPSTREAM.md` for the official starter source used to bootstrap this directory.

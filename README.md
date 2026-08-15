# Sami Shope

Sami Shope is organized as two clearly separated applications:

- `frontend/` — Flutter client application.
- `backend/` — Medusa commerce backend.

## Repository structure

```text
Sami-shope/
├── frontend/
├── backend/
├── .github/
├── .gitignore
└── README.md
```

## Development rules

- Frontend and backend remain independent.
- No backend business logic or server secrets go into `frontend/`.
- Project-specific backend behavior is added through supported Medusa extension points; Medusa core is not modified directly.
- Production secrets are never committed. Only templates such as `.env.template` may be tracked.
- Work is developed on dedicated branches and merged through pull requests.
- The first milestone is a single-store end-to-end flow before multi-store and realtime features are added.

## Implementation order

1. Bootstrap and verify the Flutter frontend.
2. Bootstrap and verify a clean Medusa backend with PostgreSQL.
3. Replace demo products in Flutter with real Medusa Store API data.
4. Complete product → cart → checkout → order.
5. Add multi-store merchant isolation.
6. Add realtime product availability and order updates.

# Sami-shope Frontend

Flutter storefront for Sami-shope.

## Architecture

The Flutter UI is kept independent from the backend. Backend access must go through repositories and the Medusa client instead of making HTTP calls directly from widgets.

Current production-oriented catalog path:

```text
UI -> ProductRepository -> MedusaClient -> Medusa Store API
```

## Backend configuration

Do not commit backend URLs or API keys into Dart source files.

Run the app with compile-time values:

```bash
flutter run \
  --dart-define=MEDUSA_BASE_URL=https://api.example.com \
  --dart-define=MEDUSA_PUBLISHABLE_KEY=pk_your_key
```

Required values:

- `MEDUSA_BASE_URL`: Medusa backend base URL.
- `MEDUSA_PUBLISHABLE_KEY`: publishable Store API key.

## Current integration

The home product strip now reads real products from:

```text
GET /store/products
```

Selecting a Medusa product opens a detail screen populated from the Store API response. Demo-only product details are not shown for products loaded from Medusa.

## Next integration steps

1. Categories.
2. Cart creation and line items.
3. Checkout and order creation.
4. Store/merchant scoping for multi-store.
5. Realtime product availability and order status.

## Upstream UI

The initial UI source was imported from `abuanwar072/E-commerce-Complete-Flutter-UI`.
See `UPSTREAM.md` and `UPSTREAM_README.md` for provenance.

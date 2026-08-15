# Upstream source

The initial backend application was imported from the official Medusa DTC starter:
`medusajs/dtc-starter/apps/backend` (`main`).

Sami-shope keeps this backend as a standalone directory and does not import the starter's Next.js storefront or monorepo wrapper.
Project-specific behavior must use supported Medusa extension points rather than modifying Medusa core.

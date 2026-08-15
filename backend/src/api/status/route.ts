import type { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"

export async function GET(_req: MedusaRequest, res: MedusaResponse) {
  res.status(200).json({
    service: "sami-shope-backend",
    status: "ok",
    medusa: "2.19.0",
  })
}

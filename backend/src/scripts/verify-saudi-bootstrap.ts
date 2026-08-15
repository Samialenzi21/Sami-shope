import type { ExecArgs } from "@medusajs/framework/types"
import {
  ContainerRegistrationKeys,
  ModuleRegistrationName,
  Modules,
} from "@medusajs/framework/utils"

export default async function verifySaudiBootstrap({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const storeModuleService = container.resolve(Modules.STORE)
  const salesChannelModuleService = container.resolve(Modules.SALES_CHANNEL)
  const regionModuleService = container.resolve(Modules.REGION)
  const apiKeyModuleService = container.resolve(Modules.API_KEY)
  const stockLocationModuleService = container.resolve(Modules.STOCK_LOCATION)
  const fulfillmentModuleService = container.resolve(
    ModuleRegistrationName.FULFILLMENT
  )

  const [stores, salesChannels, regions, apiKeys, stockLocations, fulfillmentSets, shippingOptions] =
    await Promise.all([
      storeModuleService.listStores({ name: "Sami Shope" }),
      salesChannelModuleService.listSalesChannels({
        name: "Sami Shope Storefront",
      }),
      regionModuleService.listRegions({ name: "Saudi Arabia" }),
      apiKeyModuleService.listApiKeys({
        title: "Sami Shope Flutter Storefront",
        type: "publishable",
      }),
      stockLocationModuleService.listStockLocations({
        name: "Sami Shope Riyadh",
      }),
      fulfillmentModuleService.listFulfillmentSets({
        name: "Sami Shope Pickup",
      }),
      fulfillmentModuleService.listShippingOptions({
        name: "Store Pickup",
      }),
    ])

  const failures: string[] = []

  if (stores.length !== 1) failures.push("Sami Shope store")
  if (salesChannels.length !== 1) failures.push("storefront sales channel")
  if (regions.length !== 1 || regions[0].currency_code !== "sar") {
    failures.push("Saudi Arabia SAR region")
  }
  if (apiKeys.length !== 1 || !apiKeys[0].token.startsWith("pk_")) {
    failures.push("publishable API key")
  }
  if (stockLocations.length !== 1) failures.push("Riyadh stock location")
  if (fulfillmentSets.length !== 1 || fulfillmentSets[0].type !== "pickup") {
    failures.push("pickup fulfillment set")
  }
  if (shippingOptions.length !== 1) failures.push("store pickup option")

  if (failures.length) {
    throw new Error(`Saudi bootstrap verification failed: ${failures.join(", ")}`)
  }

  logger.info("Saudi bootstrap verification passed.")
  logger.info(`Publishable API key: ${apiKeys[0].token}`)
}

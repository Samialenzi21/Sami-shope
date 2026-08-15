import type { ExecArgs } from "@medusajs/framework/types"
import {
  ContainerRegistrationKeys,
  ModuleRegistrationName,
  Modules,
} from "@medusajs/framework/utils"
import {
  createApiKeysWorkflow,
  createRegionsWorkflow,
  createSalesChannelsWorkflow,
  createShippingOptionsWorkflow,
  createStockLocationsWorkflow,
  createStoresWorkflow,
  createTaxRegionsWorkflow,
  linkSalesChannelsToApiKeyWorkflow,
  linkSalesChannelsToStockLocationWorkflow,
} from "@medusajs/medusa/core-flows"

const STORE_NAME = "Sami Shope"
const SALES_CHANNEL_NAME = "Sami Shope Storefront"
const API_KEY_TITLE = "Sami Shope Flutter Storefront"
const REGION_NAME = "Saudi Arabia"
const STOCK_LOCATION_NAME = "Sami Shope Riyadh"
const FULFILLMENT_SET_NAME = "Sami Shope Pickup"
const PICKUP_OPTION_NAME = "Store Pickup"

export default async function bootstrapSaudiCommerce({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const link = container.resolve(ContainerRegistrationKeys.LINK)
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const storeModuleService = container.resolve(Modules.STORE)
  const apiKeyModuleService = container.resolve(Modules.API_KEY)
  const fulfillmentModuleService = container.resolve(
    ModuleRegistrationName.FULFILLMENT
  )

  const existingStores = await storeModuleService.listStores({
    name: STORE_NAME,
  })

  if (existingStores.length) {
    const existingKeys = await apiKeyModuleService.listApiKeys({
      title: API_KEY_TITLE,
      type: "publishable",
    })

    logger.info("Saudi commerce bootstrap already exists; no changes made.")
    if (existingKeys[0]) {
      logger.info(`Publishable API key: ${existingKeys[0].token}`)
    }
    return
  }

  logger.info("Creating Sami Shope Saudi commerce foundation...")

  const {
    result: [salesChannel],
  } = await createSalesChannelsWorkflow(container).run({
    input: {
      salesChannelsData: [
        {
          name: SALES_CHANNEL_NAME,
          description: "Flutter storefront sales channel",
        },
      ],
    },
  })

  const {
    result: [publishableApiKey],
  } = await createApiKeysWorkflow(container).run({
    input: {
      api_keys: [
        {
          title: API_KEY_TITLE,
          type: "publishable",
          created_by: "bootstrap",
        },
      ],
    },
  })

  await linkSalesChannelsToApiKeyWorkflow(container).run({
    input: {
      id: publishableApiKey.id,
      add: [salesChannel.id],
    },
  })

  const {
    result: [region],
  } = await createRegionsWorkflow(container).run({
    input: {
      regions: [
        {
          name: REGION_NAME,
          currency_code: "sar",
          countries: ["sa"],
          payment_providers: ["pp_system_default"],
        },
      ],
    },
  })

  await createTaxRegionsWorkflow(container).run({
    input: [
      {
        country_code: "sa",
        provider_id: "tp_system",
      },
    ],
  })

  const {
    result: [stockLocation],
  } = await createStockLocationsWorkflow(container).run({
    input: {
      locations: [
        {
          name: STOCK_LOCATION_NAME,
          address: {
            city: "Riyadh",
            country_code: "SA",
            address_1: "Riyadh",
          },
        },
      ],
    },
  })

  await link.create({
    [Modules.STOCK_LOCATION]: {
      stock_location_id: stockLocation.id,
    },
    [Modules.FULFILLMENT]: {
      fulfillment_provider_id: "manual_manual",
    },
  })

  const fulfillmentSet = await fulfillmentModuleService.createFulfillmentSets({
    name: FULFILLMENT_SET_NAME,
    type: "pickup",
    service_zones: [
      {
        name: "Saudi Arabia Pickup",
        geo_zones: [
          {
            country_code: "sa",
            type: "country",
          },
        ],
      },
    ],
  })

  await link.create({
    [Modules.STOCK_LOCATION]: {
      stock_location_id: stockLocation.id,
    },
    [Modules.FULFILLMENT]: {
      fulfillment_set_id: fulfillmentSet.id,
    },
  })

  const { data: shippingProfiles } = await query.graph({
    entity: "shipping_profile",
    fields: ["id"],
  })

  if (!shippingProfiles[0]) {
    throw new Error("Default Medusa shipping profile was not found.")
  }

  await createShippingOptionsWorkflow(container).run({
    input: [
      {
        name: PICKUP_OPTION_NAME,
        price_type: "flat",
        provider_id: "manual_manual",
        service_zone_id: fulfillmentSet.service_zones[0].id,
        shipping_profile_id: shippingProfiles[0].id,
        type: {
          label: "Pickup",
          description: "Collect the order from the store.",
          code: "pickup",
        },
        prices: [
          {
            region_id: region.id,
            amount: 0,
          },
        ],
        rules: [
          {
            attribute: "enabled_in_store",
            value: "true",
            operator: "eq",
          },
          {
            attribute: "is_return",
            value: "false",
            operator: "eq",
          },
        ],
      },
    ],
  })

  await linkSalesChannelsToStockLocationWorkflow(container).run({
    input: {
      id: stockLocation.id,
      add: [salesChannel.id],
    },
  })

  await createStoresWorkflow(container).run({
    input: {
      stores: [
        {
          name: STORE_NAME,
          supported_currencies: [
            {
              currency_code: "sar",
              is_default: true,
            },
          ],
          default_sales_channel_id: salesChannel.id,
        },
      ],
    },
  })

  logger.info("Saudi commerce bootstrap completed.")
  logger.info(`Region: ${REGION_NAME} (SAR)`)
  logger.info(`Pickup option: ${PICKUP_OPTION_NAME} (0 SAR)`)
  logger.info(`Publishable API key: ${publishableApiKey.token}`)
}

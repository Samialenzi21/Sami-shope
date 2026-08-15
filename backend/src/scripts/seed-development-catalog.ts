import type { ExecArgs } from "@medusajs/framework/types"
import {
  ContainerRegistrationKeys,
  ProductStatus,
} from "@medusajs/framework/utils"
import {
  createProductCategoriesWorkflow,
  createProductsWorkflow,
} from "@medusajs/medusa/core-flows"
import bootstrapSaudiCommerce from "./bootstrap-saudi"

const SALES_CHANNEL_NAME = "Sami Shope Storefront"
const CATEGORY_NAMES = ["Coffee", "Cold Drinks", "Desserts"] as const

const DEV_PRODUCTS = [
  {
    title: "Spanish Latte",
    handle: "dev-spanish-latte",
    description: "Development catalog item for Flutter integration.",
    category: "Coffee",
    price: 18,
    sku: "DEV-SPANISH-LATTE-REGULAR",
  },
  {
    title: "V60",
    handle: "dev-v60",
    description: "Development catalog item for Flutter integration.",
    category: "Coffee",
    price: 16,
    sku: "DEV-V60-REGULAR",
  },
  {
    title: "Iced Latte",
    handle: "dev-iced-latte",
    description: "Development catalog item for Flutter integration.",
    category: "Cold Drinks",
    price: 17,
    sku: "DEV-ICED-LATTE-REGULAR",
  },
  {
    title: "Chocolate Brownie",
    handle: "dev-chocolate-brownie",
    description: "Development catalog item for Flutter integration.",
    category: "Desserts",
    price: 12,
    sku: "DEV-CHOCOLATE-BROWNIE",
  },
] as const

export default async function seedDevelopmentCatalog({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  await bootstrapSaudiCommerce({ container, args: [] })

  const { data: salesChannels } = await query.graph({
    entity: "sales_channel",
    fields: ["id", "name"],
    filters: { name: SALES_CHANNEL_NAME },
  })
  const salesChannel = salesChannels[0]
  if (!salesChannel) {
    throw new Error("Sami Shope storefront sales channel was not found.")
  }

  const { data: shippingProfiles } = await query.graph({
    entity: "shipping_profile",
    fields: ["id"],
  })
  const shippingProfile = shippingProfiles[0]
  if (!shippingProfile) {
    throw new Error("Default Medusa shipping profile was not found.")
  }

  const { data: existingCategories } = await query.graph({
    entity: "product_category",
    fields: ["id", "name"],
  })

  const categoriesByName = new Map(
    existingCategories.map((category) => [category.name, category.id])
  )

  const missingCategoryNames = CATEGORY_NAMES.filter(
    (name) => !categoriesByName.has(name)
  )

  if (missingCategoryNames.length) {
    const { result: createdCategories } = await createProductCategoriesWorkflow(
      container
    ).run({
      input: {
        product_categories: missingCategoryNames.map((name) => ({
          name,
          is_active: true,
        })),
      },
    })

    for (const category of createdCategories) {
      categoriesByName.set(category.name, category.id)
    }
  }

  const { data: existingProducts } = await query.graph({
    entity: "product",
    fields: ["id", "handle"],
  })
  const existingHandles = new Set(existingProducts.map((product) => product.handle))

  const missingProducts = DEV_PRODUCTS.filter(
    (product) => !existingHandles.has(product.handle)
  )

  if (!missingProducts.length) {
    logger.info("Development catalog already exists; no changes made.")
    return
  }

  await createProductsWorkflow(container).run({
    input: {
      products: missingProducts.map((product) => {
        const categoryId = categoriesByName.get(product.category)
        if (!categoryId) {
          throw new Error(`Category ${product.category} was not created.`)
        }

        return {
          title: product.title,
          handle: product.handle,
          description: product.description,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          category_ids: [categoryId],
          sales_channels: [{ id: salesChannel.id }],
          options: [
            {
              title: "Size",
              values: ["Regular"],
            },
          ],
          variants: [
            {
              title: "Regular",
              sku: product.sku,
              manage_inventory: false,
              options: {
                Size: "Regular",
              },
              prices: [
                {
                  currency_code: "sar",
                  amount: product.price,
                },
              ],
            },
          ],
        }
      }),
    },
  })

  logger.info(`Development catalog seeded with ${missingProducts.length} products.`)
}

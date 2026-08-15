import { medusaIntegrationTestRunner } from "@medusajs/test-utils"
import {
  ContainerRegistrationKeys,
  Modules,
  ProductStatus,
} from "@medusajs/framework/utils"
import { createProductsWorkflow } from "@medusajs/medusa/core-flows"
import bootstrapSaudiCommerce from "../../src/scripts/bootstrap-saudi"

medusaIntegrationTestRunner({
  testSuite: ({ api, getContainer }) => {
    describe("Saudi pickup order flow", () => {
      it("creates a SAR order through the public Store API", async () => {
        const container = getContainer()

        await bootstrapSaudiCommerce({ container, args: [] })

        const salesChannelModule = container.resolve(Modules.SALES_CHANNEL)
        const regionModule = container.resolve(Modules.REGION)
        const apiKeyModule = container.resolve(Modules.API_KEY)
        const query = container.resolve(ContainerRegistrationKeys.QUERY)

        const [salesChannel] = await salesChannelModule.listSalesChannels({
          name: "Sami Shope Storefront",
        })
        const [region] = await regionModule.listRegions({
          name: "Saudi Arabia",
        })
        const [publishableKey] = await apiKeyModule.listApiKeys({
          title: "Sami Shope Flutter Storefront",
          type: "publishable",
        })

        if (!salesChannel || !region || !publishableKey) {
          throw new Error("Saudi commerce bootstrap did not create required data.")
        }

        expect(region.currency_code).toBe("sar")
        expect(publishableKey.token).toMatch(/^pk_/)

        const { data: shippingProfiles } = await query.graph({
          entity: "shipping_profile",
          fields: ["id"],
        })
        const shippingProfile = shippingProfiles[0]
        if (!shippingProfile) {
          throw new Error("Default shipping profile was not found.")
        }

        const {
          result: [product],
        } = await createProductsWorkflow(container).run({
          input: {
            products: [
              {
                title: "E2E Spanish Latte",
                description: "Integration-test-only product",
                status: ProductStatus.PUBLISHED,
                shipping_profile_id: shippingProfile.id,
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
                    sku: `e2e-spanish-latte-${Date.now()}`,
                    manage_inventory: false,
                    options: {
                      Size: "Regular",
                    },
                    prices: [
                      {
                        currency_code: "sar",
                        amount: 18,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        })

        if (!product?.variants?.[0]) {
          throw new Error("E2E product variant was not created.")
        }

        const storeHeaders = {
          headers: {
            "x-publishable-api-key": publishableKey.token,
          },
        }

        const productsResponse = await api.get(
          `/store/products?region_id=${region.id}&id=${product.id}`,
          storeHeaders
        )
        expect(productsResponse.status).toBe(200)
        expect(productsResponse.data.products).toHaveLength(1)
        expect(productsResponse.data.products[0].variants[0].calculated_price.currency_code).toBe(
          "sar"
        )

        const variantId = product.variants[0].id
        const cartResponse = await api.post(
          "/store/carts",
          {
            region_id: region.id,
            sales_channel_id: salesChannel.id,
            email: "e2e@example.com",
            shipping_address: {
              first_name: "E2E",
              last_name: "Customer",
              phone: "0500000000",
              address_1: "Store Pickup",
              city: "Riyadh",
              country_code: "sa",
            },
            billing_address: {
              first_name: "E2E",
              last_name: "Customer",
              phone: "0500000000",
              address_1: "Store Pickup",
              city: "Riyadh",
              country_code: "sa",
            },
            items: [{ variant_id: variantId, quantity: 2 }],
          },
          storeHeaders
        )

        expect(cartResponse.status).toBe(200)
        const cart = cartResponse.data.cart
        expect(cart.currency_code).toBe("sar")
        expect(cart.items).toHaveLength(1)
        expect(cart.items[0].quantity).toBe(2)

        const shippingResponse = await api.get(
          `/store/shipping-options?cart_id=${cart.id}`,
          storeHeaders
        )
        expect(shippingResponse.status).toBe(200)

        const pickupOption = shippingResponse.data.shipping_options.find(
          (option: { id: string; name: string }) => option.name === "Store Pickup"
        )
        if (!pickupOption) {
          throw new Error("Store Pickup shipping option was not returned.")
        }

        const shippingMethodResponse = await api.post(
          `/store/carts/${cart.id}/shipping-methods`,
          { option_id: pickupOption.id },
          storeHeaders
        )
        expect(shippingMethodResponse.status).toBe(200)

        const paymentCollectionResponse = await api.post(
          "/store/payment-collections",
          { cart_id: cart.id },
          storeHeaders
        )
        expect(paymentCollectionResponse.status).toBe(200)
        const paymentCollection = paymentCollectionResponse.data.payment_collection
        expect(paymentCollection.id).toBeDefined()

        const paymentSessionResponse = await api.post(
          `/store/payment-collections/${paymentCollection.id}/payment-sessions`,
          { provider_id: "pp_system_default" },
          storeHeaders
        )
        expect(paymentSessionResponse.status).toBe(200)

        const completionResponse = await api.post(
          `/store/carts/${cart.id}/complete`,
          {},
          storeHeaders
        )
        expect(completionResponse.status).toBe(200)
        expect(completionResponse.data.type).toBe("order")
        expect(completionResponse.data.order.id).toBeDefined()
        expect(completionResponse.data.order.currency_code).toBe("sar")
        expect(completionResponse.data.order.items).toHaveLength(1)
        expect(completionResponse.data.order.items[0].quantity).toBe(2)
      })
    })
  },
})

jest.setTimeout(120 * 1000)

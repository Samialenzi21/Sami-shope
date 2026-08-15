import { medusaIntegrationTestRunner } from "@medusajs/test-utils"

medusaIntegrationTestRunner({
  testSuite: ({ api }) => {
    describe("GET /status", () => {
      it("reports that the Sami Shope backend is healthy", async () => {
        const response = await api.get("/status")

        expect(response.status).toBe(200)
        expect(response.data).toEqual({
          service: "sami-shope-backend",
          status: "ok",
          medusa: "2.19.0",
        })
      })
    })
  },
})

jest.setTimeout(60 * 1000)

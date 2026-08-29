require 'rails_helper'

RSpec.describe "Webhooks::Stripe", type: :request do
  let(:tenant) { create(:tenant, plan: "starter", stripe_customer_id: "cus_webhook_test") }

  describe "POST /webhooks/stripe" do
    it "processes checkout.session.completed event" do
      payload = {
        type: "checkout.session.completed",
        data: {
          object: {
            customer: "cus_webhook_test",
            subscription: "sub_new_123",
            metadata: {
              tenant_id: tenant.id,
              plan: "enterprise"
            }
          }
        }
      }.to_json

      post "/webhooks/stripe", params: payload, headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:ok)
      tenant.reload
      expect(tenant.subscription_status).to eq("active")
      expect(tenant.plan).to eq("enterprise")
      expect(tenant.stripe_subscription_id).to eq("sub_new_123")
    end
  end
end

require 'rails_helper'
require 'ostruct'

RSpec.describe StripeServices::WebhookHandler do
  let(:tenant) { create(:tenant, plan: "starter", subscription_status: "trialing", stripe_customer_id: "cus_123") }

  describe "checkout.session.completed" do
    it "activates the subscription and updates plan" do
      session_data = OpenStruct.new(
        customer: "cus_123",
        subscription: "sub_456",
        metadata: OpenStruct.new(tenant_id: tenant.id, plan: "pro")
      )
      event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: session_data))

      described_class.new(event).call

      tenant.reload
      expect(tenant.subscription_status).to eq("active")
      expect(tenant.stripe_subscription_id).to eq("sub_456")
      expect(tenant.plan).to eq("pro")
    end
  end

  describe "customer.subscription.deleted" do
    it "marks tenant subscription as canceled" do
      tenant.update!(stripe_subscription_id: "sub_active", subscription_status: "active")

      subscription_data = OpenStruct.new(id: "sub_active", customer: "cus_123")
      event = OpenStruct.new(type: "customer.subscription.deleted", data: OpenStruct.new(object: subscription_data))

      described_class.new(event).call

      expect(tenant.reload.subscription_status).to eq("canceled")
    end
  end

  describe "invoice.payment_failed" do
    it "marks tenant subscription as past_due" do
      tenant.update!(stripe_subscription_id: "sub_active", subscription_status: "active")

      invoice_data = OpenStruct.new(subscription: "sub_active", customer: "cus_123")
      event = OpenStruct.new(type: "invoice.payment_failed", data: OpenStruct.new(object: invoice_data))

      described_class.new(event).call

      expect(tenant.reload.subscription_status).to eq("past_due")
    end
  end
end

require 'rails_helper'

RSpec.describe StripeServices::CheckoutSessionCreator do
  let(:tenant) { create(:tenant, plan: "starter") }
  let(:user) { create(:user, tenant: tenant, email: "admin@salao.com") }

  subject(:creator) do
    described_class.new(
      tenant: tenant,
      plan: "pro",
      user: user,
      success_url: "http://localhost:3000/success",
      cancel_url: "http://localhost:3000/cancel"
    )
  end

  describe "#call" do
    it "creates a stripe customer and a checkout session" do
      fake_customer = double("Stripe::Customer", id: "cus_test123")
      fake_session = double("Stripe::Checkout::Session", id: "cs_test123", url: "https://checkout.stripe.com/pay/cs_test123")

      allow(Stripe::Customer).to receive(:create).and_return(fake_customer)
      allow(Stripe::Checkout::Session).to receive(:create).and_return(fake_session)

      result = creator.call

      expect(result).to eq(fake_session)
      expect(tenant.reload.stripe_customer_id).to eq("cus_test123")
    end

    it "reuses existing stripe_customer_id" do
      tenant.update!(stripe_customer_id: "cus_existing123")
      fake_session = double("Stripe::Checkout::Session", id: "cs_test123", url: "https://checkout.stripe.com/pay/cs_test123")

      expect(Stripe::Customer).not_to receive(:create)
      allow(Stripe::Checkout::Session).to receive(:create).and_return(fake_session)

      result = creator.call
      expect(result).to eq(fake_session)
    end

    it "returns nil and populates errors for invalid plan" do
      invalid_creator = described_class.new(
        tenant: tenant,
        plan: "nonexistent",
        user: user,
        success_url: "http://localhost:3000/success",
        cancel_url: "http://localhost:3000/cancel"
      )

      expect(invalid_creator.call).to be_nil
      expect(invalid_creator.errors).to include("Plano inválido selecionado.")
    end
  end
end

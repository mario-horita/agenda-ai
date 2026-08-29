require 'rails_helper'

RSpec.describe StripeServices::CustomerPortalCreator do
  let(:tenant) { create(:tenant, stripe_customer_id: "cus_test123") }

  describe "#call" do
    it "creates a billing portal session" do
      fake_portal = double("Stripe::BillingPortal::Session", url: "https://billing.stripe.com/p/session_test")
      allow(Stripe::BillingPortal::Session).to receive(:create).and_return(fake_portal)

      creator = described_class.new(tenant: tenant, return_url: "http://localhost:3000/return")
      result = creator.call

      expect(result).to eq(fake_portal)
    end

    it "returns nil with error if tenant has no stripe_customer_id" do
      tenant.update!(stripe_customer_id: nil)
      creator = described_class.new(tenant: tenant, return_url: "http://localhost:3000/return")

      expect(creator.call).to be_nil
      expect(creator.errors).to include("Nenhum cliente Stripe associado a esta empresa.")
    end
  end
end

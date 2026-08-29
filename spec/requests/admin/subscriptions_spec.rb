require 'rails_helper'

RSpec.describe "Admin::Subscriptions", type: :request do
  let(:tenant) { create(:tenant, plan: "starter") }
  let(:user) { create(:user, tenant: tenant) }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin/subscription" do
    it "renders the subscription and pricing page" do
      get admin_subscription_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Planos &amp; Assinatura").or include("Planos & Assinatura")
      expect(response.body).to include("Starter")
      expect(response.body).to include("Pro")
      expect(response.body).to include("Enterprise")
    end
  end

  describe "POST /:tenant_slug/admin/subscription" do
    it "initiates checkout and redirects to stripe checkout session url" do
      fake_session = double("Stripe::Checkout::Session", url: "https://checkout.stripe.com/c/pay/cs_test_abc")
      allow_any_instance_of(StripeServices::CheckoutSessionCreator).to receive(:call).and_return(fake_session)

      post admin_subscription_path(tenant_slug: tenant.slug), params: { plan: "pro" }
      expect(response).to redirect_to("https://checkout.stripe.com/c/pay/cs_test_abc")
    end
  end

  describe "POST /:tenant_slug/admin/subscription/portal" do
    it "redirects to stripe customer portal url" do
      fake_portal = double("Stripe::BillingPortal::Session", url: "https://billing.stripe.com/p/session_test")
      allow_any_instance_of(StripeServices::CustomerPortalCreator).to receive(:call).and_return(fake_portal)

      post portal_admin_subscription_path(tenant_slug: tenant.slug)
      expect(response).to redirect_to("https://billing.stripe.com/p/session_test")
    end
  end
end

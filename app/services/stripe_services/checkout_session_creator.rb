module StripeServices
  class CheckoutSessionCreator
    attr_reader :tenant, :plan, :user, :success_url, :cancel_url, :errors

    def initialize(tenant:, plan:, user:, success_url:, cancel_url:)
      @tenant = tenant
      @plan = plan.to_s
      @user = user
      @success_url = success_url
      @cancel_url = cancel_url
      @errors = []
    end

    def call
      plan_info = Tenant::PLANS[plan]
      unless plan_info
        @errors << "Plano inválido selecionado."
        return nil
      end

      # 1. Resolve or create Stripe customer
      customer_id = resolve_customer_id!

      # 2. Create Stripe Checkout Session
      session = Stripe::Checkout::Session.create(
        customer: customer_id,
        payment_method_types: [ "card" ],
        mode: "subscription",
        line_items: [
          {
            price_data: {
              currency: "brl",
              product_data: {
                name: "Agenda AI — Plano #{plan_info[:name]}",
                description: plan_info[:features].join(" • ")
              },
              unit_amount: plan_info[:price_cents],
              recurring: { interval: "month" }
            },
            quantity: 1
          }
        ],
        metadata: {
          tenant_id: tenant.id,
          plan: plan
        },
        subscription_data: {
          metadata: {
            tenant_id: tenant.id,
            plan: plan
          }
        },
        success_url: success_url,
        cancel_url: cancel_url
      )

      session
    rescue Stripe::StripeError => e
      @errors << e.message
      nil
    end

    private

    def resolve_customer_id!
      return tenant.stripe_customer_id if tenant.stripe_customer_id.present?

      customer = Stripe::Customer.create(
        email: user.email,
        name: tenant.name,
        metadata: { tenant_id: tenant.id }
      )

      tenant.update!(stripe_customer_id: customer.id)
      customer.id
    end
  end
end

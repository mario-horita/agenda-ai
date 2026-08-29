module StripeServices
  class CustomerPortalCreator
    attr_reader :tenant, :return_url, :errors

    def initialize(tenant:, return_url:)
      @tenant = tenant
      @return_url = return_url
      @errors = []
    end

    def call
      unless tenant.stripe_customer_id.present?
        @errors << "Nenhum cliente Stripe associado a esta empresa."
        return nil
      end

      session = Stripe::BillingPortal::Session.create(
        customer: tenant.stripe_customer_id,
        return_url: return_url
      )

      session
    rescue Stripe::StripeError => e
      @errors << e.message
      nil
    end
  end
end

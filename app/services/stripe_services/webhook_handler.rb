module StripeServices
  class WebhookHandler
    attr_reader :event

    def initialize(event)
      @event = event
    end

    def call
      case event.type
      when "checkout.session.completed"
        handle_checkout_session_completed(event.data.object)
      when "customer.subscription.updated"
        handle_subscription_updated(event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      when "invoice.payment_succeeded"
        handle_invoice_payment_succeeded(event.data.object)
      when "invoice.payment_failed"
        handle_invoice_payment_failed(event.data.object)
      end
    end

    private

    def handle_checkout_session_completed(session)
      tenant_id = session.metadata&.tenant_id
      plan = session.metadata&.plan

      tenant = find_tenant_by_id_or_customer(tenant_id, session.customer)
      return unless tenant

      subscription_id = session.subscription
      tenant.update!(
        stripe_customer_id: session.customer,
        stripe_subscription_id: subscription_id,
        subscription_status: :active,
        plan: plan.presence || tenant.plan
      )
    end

    def handle_subscription_updated(subscription)
      tenant = Tenant.find_by(stripe_subscription_id: subscription.id) ||
               Tenant.find_by(stripe_customer_id: subscription.customer)
      return unless tenant

      status = map_stripe_status(subscription.status)
      period_end = subscription.current_period_end ? Time.zone.at(subscription.current_period_end) : nil

      tenant.update!(
        stripe_subscription_id: subscription.id,
        subscription_status: status,
        current_period_end: period_end
      )
    end

    def handle_subscription_deleted(subscription)
      tenant = Tenant.find_by(stripe_subscription_id: subscription.id) ||
               Tenant.find_by(stripe_customer_id: subscription.customer)
      return unless tenant

      tenant.update!(subscription_status: :canceled)
    end

    def handle_invoice_payment_succeeded(invoice)
      return unless invoice.subscription.present?

      tenant = Tenant.find_by(stripe_subscription_id: invoice.subscription) ||
               Tenant.find_by(stripe_customer_id: invoice.customer)
      return unless tenant

      tenant.update!(subscription_status: :active)
    end

    def handle_invoice_payment_failed(invoice)
      return unless invoice.subscription.present?

      tenant = Tenant.find_by(stripe_subscription_id: invoice.subscription) ||
               Tenant.find_by(stripe_customer_id: invoice.customer)
      return unless tenant

      tenant.update!(subscription_status: :past_due)
    end

    def find_tenant_by_id_or_customer(tenant_id, customer_id)
      if tenant_id.present?
        Tenant.find_by(id: tenant_id)
      elsif customer_id.present?
        Tenant.find_by(stripe_customer_id: customer_id)
      end
    end

    def map_stripe_status(stripe_status)
      case stripe_status
      when "active" then "active"
      when "trialing" then "trialing"
      when "past_due" then "past_due"
      when "canceled" then "canceled"
      when "unpaid" then "unpaid"
      else "trialing"
      end
    end
  end
end

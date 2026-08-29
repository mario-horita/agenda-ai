module Admin
  class SubscriptionsController < BaseController
    def show
      @tenant = current_tenant
      @plans = Tenant::PLANS
    end

    def create
      plan = params[:plan]

      creator = StripeServices::CheckoutSessionCreator.new(
        tenant: current_tenant,
        plan: plan,
        user: current_user,
        success_url: success_admin_subscription_url(tenant_slug: current_tenant.slug),
        cancel_url: cancel_admin_subscription_url(tenant_slug: current_tenant.slug)
      )

      session = creator.call

      if session
        redirect_to session.url, allow_other_host: true, status: :see_other
      else
        redirect_to admin_subscription_path(tenant_slug: current_tenant.slug),
                    alert: creator.errors.first || "Não foi possível iniciar o checkout no Stripe."
      end
    end

    def portal
      portal_creator = StripeServices::CustomerPortalCreator.new(
        tenant: current_tenant,
        return_url: admin_subscription_url(tenant_slug: current_tenant.slug)
      )

      session = portal_creator.call

      if session
        redirect_to session.url, allow_other_host: true, status: :see_other
      else
        redirect_to admin_subscription_path(tenant_slug: current_tenant.slug),
                    alert: portal_creator.errors.first || "Não foi possível abrir o portal de faturas do Stripe."
      end
    end

    def success
      redirect_to admin_subscription_path(tenant_slug: current_tenant.slug),
                  notice: "🎉 Pagamento realizado com sucesso! Sua assinatura foi atualizada."
    end

    def cancel
      redirect_to admin_subscription_path(tenant_slug: current_tenant.slug),
                  alert: "O checkout no Stripe foi cancelado. Nenhuma cobrança foi realizada."
    end
  end
end

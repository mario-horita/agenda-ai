class OnboardingController < ApplicationController
  skip_before_action :set_current_tenant_from_slug, raise: false
  layout "application"

  def new
    @selected_plan = params[:plan].presence || "pro"
    @tenant = Tenant.new(plan: @selected_plan)
    @user = User.new
    @plans = Tenant::PLANS
  end

  def create
    @selected_plan = tenant_params[:plan].presence || "pro"

    service = Onboarding::TenantSetup.new(
      tenant_params: tenant_params.merge(
        plan: @selected_plan,
        trial_ends_at: 14.days.from_now
      ),
      user_params: user_params
    )

    result = service.call

    if result
      user = result[:user]
      tenant = result[:tenant]

      # Log in the new tenant admin
      sign_in(user)

      if @selected_plan.in?(%w[pro enterprise])
        # Redirect to subscription page to review and checkout with Stripe
        redirect_to admin_subscription_path(tenant_slug: tenant.slug),
                    notice: "🎉 Conta criada com sucesso! Você tem 14 dias de teste gratuito no plano #{@selected_plan.capitalize}."
      else
        redirect_to admin_root_path(tenant_slug: tenant.slug),
                    notice: "🎉 Bem-vindo ao Agenda AI! Sua conta no plano Starter foi criada."
      end
    else
      @tenant = Tenant.new(tenant_params)
      @user = User.new(user_params)
      @plans = Tenant::PLANS
      flash.now[:alert] = service.errors.first || "Não foi possível criar sua conta. Verifique os dados."
      render :new, status: :unprocessable_content
    end
  end

  private

  def tenant_params
    params.require(:tenant).permit(:name, :slug, :phone, :plan)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end

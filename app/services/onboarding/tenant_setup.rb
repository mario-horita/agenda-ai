module Onboarding
  class TenantSetup
    attr_reader :errors, :tenant, :user

    def initialize(tenant_params:, user_params:)
      @tenant_params = tenant_params
      @user_params = user_params
      @errors = []
    end

    def call
      ActiveRecord::Base.transaction do
        @tenant = Tenant.create!(@tenant_params)
        @user = User.create!(
          @user_params.merge(tenant: @tenant, role: :admin)
        )
        # tenant_setting is automatically created via Tenant#after_create callback

        { tenant: @tenant, user: @user }
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      nil
    end
  end
end

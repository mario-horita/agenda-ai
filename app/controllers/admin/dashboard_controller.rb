module Admin
  class DashboardController < BaseController
    def index
      @tenant = current_tenant
      @period = params[:period].presence || "this_month"

      service = Analytics::DashboardMetrics.new(
        tenant: current_tenant,
        period: @period,
        start_date: params[:start_date],
        end_date: params[:end_date]
      )

      @metrics = service.call
    end
  end
end

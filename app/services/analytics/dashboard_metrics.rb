module Analytics
  class DashboardMetrics
    attr_reader :tenant, :period, :start_date, :end_date, :timezone

    def initialize(tenant:, period: "this_month", start_date: nil, end_date: nil)
      @tenant = tenant
      @period = period.to_s
      @timezone = tenant&.timezone || "America/Sao_Paulo"
      compute_date_range(start_date, end_date)
    end

    def call
      scoped_appointments = tenant.appointments.where(starts_at: start_date.beginning_of_day..end_date.end_of_day)

      total = scoped_appointments.count
      completed = scoped_appointments.where(status: "completed").count
      confirmed = scoped_appointments.where(status: "confirmed").count
      cancelled = scoped_appointments.where(status: "cancelled").count
      no_show = scoped_appointments.where(status: "no_show").count

      no_show_rate = total.positive? ? ((no_show.to_f / total) * 100).round(1) : 0.0
      cancellation_rate = total.positive? ? ((cancelled.to_f / total) * 100).round(1) : 0.0

      revenue_cents = scoped_appointments.where(status: [ "completed", "confirmed" ]).sum(:price_cents)
      revenue_reais = revenue_cents / 100.0

      today_date = Time.use_zone(timezone) { Date.current }
      upcoming_today = tenant.appointments.where(starts_at: today_date.beginning_of_day..today_date.end_of_day)
                                          .includes(:client, :professional, :service)
                                          .order(:starts_at)

      {
        period: period,
        start_date: start_date,
        end_date: end_date,
        total_appointments: total,
        completed_count: completed,
        confirmed_count: confirmed,
        cancelled_count: cancelled,
        no_show_count: no_show,
        no_show_rate: no_show_rate,
        cancellation_rate: cancellation_rate,
        total_revenue_cents: revenue_cents,
        total_revenue_reais: revenue_reais,
        appointments_by_day: compute_daily_appointments(scoped_appointments),
        top_services: compute_top_services(scoped_appointments),
        top_professionals: compute_top_professionals(scoped_appointments),
        upcoming_today: upcoming_today
      }
    end

    private

    def compute_date_range(custom_start, custom_end)
      Time.use_zone(timezone) do
        today = Date.current

        if custom_start.present? && custom_end.present?
          @start_date = custom_start.is_a?(String) ? Date.parse(custom_start) : custom_start
          @end_date = custom_end.is_a?(String) ? Date.parse(custom_end) : custom_end
        else
          case period
          when "today"
            @start_date = today
            @end_date = today
          when "this_week"
            @start_date = today.beginning_of_week
            @end_date = today.end_of_week
          when "last_30_days"
            @start_date = today - 30.days
            @end_date = today
          else # "this_month"
            @start_date = today.beginning_of_month
            @end_date = today.end_of_month
          end
        end
      end
    end

    def compute_daily_appointments(scoped_appointments)
      days_map = {}
      (start_date..end_date).each do |d|
        days_map[d.strftime("%d/%m")] = 0
      end

      scoped_appointments.each do |appt|
        day_key = appt.starts_at.in_time_zone(timezone).strftime("%d/%m")
        days_map[day_key] = (days_map[day_key] || 0) + 1 if days_map.key?(day_key)
      end

      days_map
    end

    def compute_top_services(scoped_appointments)
      scoped_appointments.where(status: [ "completed", "confirmed" ])
                         .joins(:service)
                         .group("services.id", "services.name")
                         .select("services.id, services.name, count(appointments.id) as appts_count, sum(appointments.price_cents) as total_price_cents")
                         .order("appts_count DESC")
                         .limit(5)
                         .map do |row|
                           {
                             name: row.name,
                             count: row.appts_count,
                             revenue_reais: (row.total_price_cents.to_i / 100.0)
                           }
                         end
    end

    def compute_top_professionals(scoped_appointments)
      scoped_appointments.where(status: [ "completed", "confirmed" ])
                         .joins(:professional)
                         .group("professionals.id", "professionals.name")
                         .select("professionals.id, professionals.name, count(appointments.id) as appts_count, sum(appointments.price_cents) as total_price_cents")
                         .order("appts_count DESC")
                         .limit(5)
                         .map do |row|
                           {
                             name: row.name,
                             count: row.appts_count,
                             revenue_reais: (row.total_price_cents.to_i / 100.0)
                           }
                         end
    end
  end
end

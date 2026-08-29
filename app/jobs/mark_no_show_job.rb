class MarkNoShowJob < ApplicationJob
  queue_as :default

  def perform
    # Find appointments that ended more than 2 hours ago and are still confirmed
    expired_appointments = Appointment.where(status: "confirmed")
                                      .where("ends_at < ?", 2.hours.ago)

    count = 0
    expired_appointments.find_each do |appt|
      appt.update!(status: :no_show)
      appt.client.increment!(:no_show_count)
      count += 1
    end

    Rails.logger.info("[MarkNoShowJob] Marcados #{count} agendamentos como no-show.")
    count
  end
end

module Notifications
  class ReminderScheduler
    attr_reader :appointment

    def initialize(appointment)
      @appointment = appointment
    end

    def schedule
      tenant = appointment.tenant
      setting = tenant.tenant_setting
      reminder_hours = setting&.reminder_hours || 24

      channels = setting ? setting.notification_channels_array : [ "email" ]
      scheduled_notifications = []

      # 1. 24h reminder
      reminder_24h_time = appointment.starts_at - reminder_hours.hours
      if reminder_24h_time > Time.current
        channels.each do |channel|
          notif = Notification.create!(
            appointment: appointment,
            channel: channel,
            notification_type: :reminder_24h,
            status: :pending,
            scheduled_for: reminder_24h_time
          )
          SendNotificationJob.set(wait_until: reminder_24h_time).perform_later(notif.id)
          scheduled_notifications << notif
        end
      end

      # 2. 2h reminder
      reminder_2h_time = appointment.starts_at - 2.hours
      if reminder_2h_time > Time.current
        channels.each do |channel|
          notif = Notification.create!(
            appointment: appointment,
            channel: channel,
            notification_type: :reminder_2h,
            status: :pending,
            scheduled_for: reminder_2h_time
          )
          SendNotificationJob.set(wait_until: reminder_2h_time).perform_later(notif.id)
          scheduled_notifications << notif
        end
      end

      scheduled_notifications
    end
  end
end

module Notifications
  class Dispatcher
    attr_reader :appointment

    def initialize(appointment)
      @appointment = appointment
    end

    def dispatch(notification_type)
      tenant = appointment.tenant
      setting = tenant.tenant_setting
      channels = setting ? setting.notification_channels_array : [ "email" ]

      created_notifications = []

      channels.each do |channel|
        notification = Notification.create!(
          appointment: appointment,
          channel: channel,
          notification_type: notification_type,
          status: :pending
        )

        SendNotificationJob.perform_later(notification.id)
        created_notifications << notification
      end

      created_notifications
    end
  end
end

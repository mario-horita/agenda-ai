class SendNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification && notification.status_pending?

    appointment = notification.appointment
    return unless appointment

    case notification.channel
    when "email"
      send_email(notification, appointment)
    when "whatsapp"
      # Evolution API / Twilio (v1.1)
      notification.update!(status: :sent, sent_at: Time.current)
    end
  end

  private

  def send_email(notification, appointment)
    case notification.notification_type
    when "confirmation"
      AppointmentMailer.booking_confirmation(appointment).deliver_now
      AppointmentMailer.professional_new_booking(appointment).deliver_now if appointment.professional.email.present?
    when "reminder_24h", "reminder_2h"
      AppointmentMailer.booking_reminder(appointment, notification.notification_type).deliver_now
    when "cancellation"
      AppointmentMailer.booking_cancellation(appointment).deliver_now
    end

    notification.update!(status: :sent, sent_at: Time.current)
  rescue StandardError => e
    notification.update!(status: :failed)
    raise e
  end
end

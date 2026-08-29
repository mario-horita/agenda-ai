class AppointmentMailer < ApplicationMailer
  def booking_confirmation(appointment)
    @appointment = appointment
    @tenant = appointment.tenant
    @client = appointment.client
    @service = appointment.service
    @professional = appointment.professional

    return unless @client.email.present?

    mail(
      to: @client.email,
      from: email_from(@tenant),
      subject: "✅ Agendamento Confirmado — #{@tenant.name}"
    )
  end

  def booking_reminder(appointment, reminder_type = "reminder_24h")
    @appointment = appointment
    @tenant = appointment.tenant
    @client = appointment.client
    @service = appointment.service
    @professional = appointment.professional
    @reminder_type = reminder_type

    return unless @client.email.present?

    subject_prefix = reminder_type == "reminder_2h" ? "⏰ Lembrete: Seu horário é daqui a 2 horas" : "⏰ Lembrete de Agendamento para Amanhã"

    mail(
      to: @client.email,
      from: email_from(@tenant),
      subject: "#{subject_prefix} — #{@tenant.name}"
    )
  end

  def booking_cancellation(appointment)
    @appointment = appointment
    @tenant = appointment.tenant
    @client = appointment.client
    @service = appointment.service
    @professional = appointment.professional

    return unless @client.email.present?

    mail(
      to: @client.email,
      from: email_from(@tenant),
      subject: "❌ Agendamento Cancelado — #{@tenant.name}"
    )
  end

  def professional_new_booking(appointment)
    @appointment = appointment
    @tenant = appointment.tenant
    @client = appointment.client
    @service = appointment.service
    @professional = appointment.professional

    return unless @professional.email.present?

    mail(
      to: @professional.email,
      from: email_from(@tenant),
      subject: "📅 Novo Agendamento Recebido: #{@client.name} — #{@service.name}"
    )
  end

  private

  def email_from(tenant)
    "#{tenant.name} <noreply@agenda-ai.com.br>"
  end
end

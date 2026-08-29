require 'rails_helper'

RSpec.describe AppointmentMailer, type: :mailer do
  let(:tenant) { create(:tenant, name: "Salão Glamour") }
  let(:client) { create(:client, tenant: tenant, name: "Ana Souza", email: "ana.souza@example.com") }
  let(:professional) { create(:professional, tenant: tenant, name: "Lucas Barbeiro", email: "lucas@salao.com") }
  let(:service) { create(:service, tenant: tenant, name: "Corte Feminino", price_cents: 8000) }
  let(:appointment) do
    create(:appointment,
           tenant: tenant,
           client: client,
           professional: professional,
           service: service,
           starts_at: Time.zone.parse("2026-09-01 10:00:00"))
  end

  describe "#booking_confirmation" do
    let(:mail) { described_class.booking_confirmation(appointment) }

    it "renders the headers" do
      expect(mail.subject).to include("Agendamento Confirmado")
      expect(mail.to).to eq([ "ana.souza@example.com" ])
      expect(mail.from).to eq([ "noreply@agenda-ai.com.br" ])
    end

    it "renders the body with appointment details" do
      expect(mail.body.encoded).to include("Ana Souza")
      expect(mail.body.encoded).to include("Corte Feminino")
      expect(mail.body.encoded).to include("Lucas Barbeiro")
    end
  end

  describe "#booking_reminder" do
    let(:mail) { described_class.booking_reminder(appointment, "reminder_24h") }

    it "renders the reminder email" do
      expect(mail.subject).to include("Lembrete de Agendamento para Amanhã")
      expect(mail.to).to eq([ "ana.souza@example.com" ])
      expect(mail.body.encoded).to include("Ana Souza")
    end
  end

  describe "#booking_cancellation" do
    before { appointment.update!(cancellation_reason: "Mudança de planos") }
    let(:mail) { described_class.booking_cancellation(appointment) }

    it "renders the cancellation email" do
      expect(mail.subject).to include("Agendamento Cancelado")
      expect(mail.to).to eq([ "ana.souza@example.com" ])
      expect(mail.body.encoded).to include("Mudança de planos")
    end
  end

  describe "#professional_new_booking" do
    let(:mail) { described_class.professional_new_booking(appointment) }

    it "renders the notification email to the professional" do
      expect(mail.subject).to include("Novo Agendamento Recebido")
      expect(mail.to).to eq([ "lucas@salao.com" ])
      expect(mail.body.encoded).to include("Ana Souza")
    end
  end
end

require 'rails_helper'

RSpec.describe Appointments::Creator do
  let(:tenant) { create(:tenant, timezone: "America/Sao_Paulo") }
  let(:professional) { create(:professional, tenant: tenant, buffer_minutes: 10) }
  let(:service) { create(:service, tenant: tenant, duration_minutes: 30, price_cents: 6000) }
  let(:target_starts_at) { Time.use_zone("America/Sao_Paulo") { (Time.zone.now + 2.days).change(hour: 14, min: 0, sec: 0) } }

  let(:client_params) do
    {
      name: "João Silva",
      email: "joao.silva@example.com",
      phone: "(11) 98765-4321"
    }
  end

  subject(:creator) do
    described_class.new(
      tenant: tenant,
      professional: professional,
      service: service,
      client_params: client_params,
      starts_at: target_starts_at
    )
  end

  describe "#call" do
    context "when slot is available" do
      it "creates the client and appointment with confirmed status" do
        expect do
          creator.call
        end.to change(Appointment, :count).by(1).and change(Client, :count).by(1)

        appointment = Appointment.last
        expect(appointment.tenant).to eq(tenant)
        expect(appointment.professional).to eq(professional)
        expect(appointment.service).to eq(service)
        expect(appointment.client.email).to eq("joao.silva@example.com")
        expect(appointment.price_cents).to eq(6000)
        expect(appointment.status).to eq("confirmed")
        expect(appointment.ends_at).to eq(target_starts_at + 30.minutes)
      end

      it "reuses existing client if email matches" do
        existing_client = create(:client, tenant: tenant, email: "joao.silva@example.com", name: "João")

        expect do
          creator.call
        end.to change(Appointment, :count).by(1).and change(Client, :count).by(0)

        expect(Appointment.last.client).to eq(existing_client)
      end
    end

    context "when slot conflicts with an existing appointment (double-booking attempt)" do
      before do
        # Existing appointment overlapping 14:00 - 14:30
        create(:appointment,
               tenant: tenant,
               professional: professional,
               service: service,
               starts_at: target_starts_at,
               ends_at: target_starts_at + 30.minutes,
               status: "confirmed")
      end

      it "prevents double-booking and returns nil with errors" do
        expect do
          result = creator.call
          expect(result).to be_nil
        end.not_to change(Appointment, :count)

        expect(creator.errors).to include("O horário selecionado não está mais disponível. Por favor, escolha outro horário.")
      end
    end

    context "when slot conflicts with a time block" do
      before do
        create(:time_block,
               professional: professional,
               start_date: target_starts_at.to_date,
               end_date: target_starts_at.to_date,
               start_time: Time.zone.parse("13:30"),
               end_time: Time.zone.parse("15:00"),
               reason: "Dentista",
               all_day: false)
      end

      it "returns nil and populates time block error" do
        result = creator.call
        expect(result).to be_nil
        expect(creator.errors.first).to include("Dentista")
      end
    end
  end
end

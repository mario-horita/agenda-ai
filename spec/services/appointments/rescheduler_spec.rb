require 'rails_helper'

RSpec.describe Appointments::Rescheduler do
  let(:tenant) { create(:tenant) }
  let!(:setting) { tenant.tenant_setting.update!(allow_reschedule: true) }
  let(:professional) { create(:professional, tenant: tenant, buffer_minutes: 0) }
  let(:service) { create(:service, tenant: tenant, duration_minutes: 30) }
  let(:appointment) { create(:appointment, tenant: tenant, professional: professional, service: service, starts_at: Time.current + 2.days) }

  let(:new_time) { (Time.current + 3.days).change(hour: 10, min: 0, sec: 0) }

  describe "#call" do
    context "when new slot is free and reschedule is allowed" do
      it "moves the appointment to the new date and time" do
        rescheduler = described_class.new(appointment: appointment, new_starts_at: new_time)
        expect(rescheduler.call).to be(true)

        expect(appointment.reload.starts_at).to eq(new_time)
        expect(appointment.ends_at).to eq(new_time + 30.minutes)
      end
    end

    context "when new slot has a conflict" do
      before do
        create(:appointment,
               tenant: tenant,
               professional: professional,
               service: service,
               starts_at: new_time,
               ends_at: new_time + 30.minutes,
               status: "confirmed")
      end

      it "returns false and does not modify the appointment" do
        rescheduler = described_class.new(appointment: appointment, new_starts_at: new_time)
        expect(rescheduler.call).to be(false)
        expect(rescheduler.errors.first).to include("não está mais disponível")
      end
    end

    context "when tenant settings disallow reschedule" do
      before { tenant.tenant_setting.update!(allow_reschedule: false) }

      it "returns false with policy error" do
        rescheduler = described_class.new(appointment: appointment, new_starts_at: new_time)
        expect(rescheduler.call).to be(false)
        expect(rescheduler.errors.first).to include("Reagendamentos não são permitidos")
      end
    end
  end
end

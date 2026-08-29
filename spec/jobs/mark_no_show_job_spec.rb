require 'rails_helper'

RSpec.describe MarkNoShowJob, type: :job do
  let(:tenant) { create(:tenant) }
  let(:client) { create(:client, tenant: tenant, no_show_count: 0) }

  let!(:expired_appointment) do
    create(:appointment,
           tenant: tenant,
           client: client,
           starts_at: 4.hours.ago,
           ends_at: 3.hours.ago,
           status: "confirmed")
  end

  let!(:future_appointment) do
    create(:appointment,
           tenant: tenant,
           starts_at: 2.hours.from_now,
           ends_at: 3.hours.from_now,
           status: "confirmed")
  end

  describe "#perform" do
    it "marks past confirmed appointments as no_show and increments counter" do
      described_class.new.perform

      expect(expired_appointment.reload.status).to eq("no_show")
      expect(client.reload.no_show_count).to eq(1)

      expect(future_appointment.reload.status).to eq("confirmed")
    end
  end
end

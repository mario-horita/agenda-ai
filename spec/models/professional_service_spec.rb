require 'rails_helper'

RSpec.describe ProfessionalService, type: :model do
  describe "associations" do
    it { should belong_to(:professional) }
    it { should belong_to(:service) }
  end

  describe "validations" do
    subject { create(:professional_service) }

    it { should validate_uniqueness_of(:professional_id).scoped_to(:service_id) }
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      ps = create(:professional_service)
      expect(ps.id).to be_present
      expect(ps.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end
end

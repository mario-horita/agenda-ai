require 'rails_helper'

RSpec.describe Availability, type: :model do
  describe "associations" do
    it { should belong_to(:professional) }
  end

  describe "validations" do
    subject { create(:availability) }

    it { should validate_presence_of(:day_of_week) }
    it { should validate_inclusion_of(:day_of_week).in_range(0..6) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }

    it "validates that end_time is strictly after start_time" do
      valid = build(:availability, start_time: Time.zone.parse("09:00"), end_time: Time.zone.parse("17:00"))
      expect(valid).to be_valid

      invalid_same = build(:availability, start_time: Time.zone.parse("09:00"), end_time: Time.zone.parse("09:00"))
      expect(invalid_same).not_to be_valid
      expect(invalid_same.errors[:end_time]).to include("deve ser posterior ao horário inicial")

      invalid_before = build(:availability, start_time: Time.zone.parse("14:00"), end_time: Time.zone.parse("10:00"))
      expect(invalid_before).not_to be_valid
    end

    it "validates uniqueness of start_time per professional and day_of_week" do
      prof = create(:professional)
      create(:availability, professional: prof, day_of_week: 1, start_time: Time.zone.parse("09:00"), end_time: Time.zone.parse("12:00"))

      duplicate = build(:availability, professional: prof, day_of_week: 1, start_time: Time.zone.parse("09:00"), end_time: Time.zone.parse("18:00"))
      expect(duplicate).not_to be_valid
    end
  end

  describe "helpers" do
    let(:availability) { build(:availability, day_of_week: 1, start_time: Time.zone.parse("09:30"), end_time: Time.zone.parse("18:00")) }

    it "returns the day name" do
      expect(availability.day_name).to eq("Segunda-feira")
    end

    it "formats time range" do
      expect(availability.time_range).to eq("09:30 às 18:00")
    end
  end
end

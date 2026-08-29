require 'rails_helper'

RSpec.describe TimeBlock, type: :model do
  describe "associations" do
    it { should belong_to(:professional) }
  end

  describe "validations" do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:reason) }

    it "validates that end_date is equal or after start_date" do
      valid = build(:time_block, start_date: Date.current, end_date: Date.current + 2.days)
      expect(valid).to be_valid

      invalid = build(:time_block, start_date: Date.current + 2.days, end_date: Date.current)
      expect(invalid).not_to be_valid
      expect(invalid.errors[:end_date]).to include("deve ser igual ou posterior à data inicial")
    end

    it "validates that end_time is after start_time if on the same day" do
      valid = build(:time_block, start_date: Date.current, end_date: Date.current, start_time: Time.zone.parse("10:00"), end_time: Time.zone.parse("12:00"))
      expect(valid).to be_valid

      invalid = build(:time_block, start_date: Date.current, end_date: Date.current, start_time: Time.zone.parse("12:00"), end_time: Time.zone.parse("10:00"))
      expect(invalid).not_to be_valid
      expect(invalid.errors[:end_time]).to include("deve ser posterior ao horário inicial")
    end
  end

  describe "helpers" do
    it "formats period for single day all day" do
      tb = build(:time_block, start_date: Date.new(2026, 9, 1), end_date: Date.new(2026, 9, 1), all_day: true)
      expect(tb.formatted_period).to include("01/09/2026 (Dia todo)")
    end

    it "formats period for date range" do
      tb = build(:time_block, start_date: Date.new(2026, 9, 1), end_date: Date.new(2026, 9, 10))
      expect(tb.formatted_period).to eq("01/09/2026 até 10/09/2026")
    end
  end
end

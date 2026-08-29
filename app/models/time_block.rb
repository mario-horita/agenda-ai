class TimeBlock < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Associations ===
  belongs_to :professional

  # === Validations ===
  validates :start_date, :end_date, :reason, presence: true
  validate :end_date_after_start_date
  validate :end_time_after_start_time_if_present

  # === Callbacks ===
  before_create :generate_id

  # === Scopes ===
  scope :overlapping_period, ->(start_d, end_d) { where("start_date <= ? AND end_date >= ?", end_d, start_d) }
  scope :ordered, -> { order(:start_date, :start_time) }

  # === Helpers ===
  def formatted_period
    if start_date == end_date
      if all_day? || start_time.blank?
        "#{start_date.strftime('%d/%m/%Y')} (Dia todo)"
      else
        "#{start_date.strftime('%d/%m/%Y')} das #{start_time.strftime('%H:%M')} às #{end_time&.strftime('%H:%M')}"
      end
    else
      "#{start_date.strftime('%d/%m/%Y')} até #{end_date.strftime('%d/%m/%Y')}"
    end
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date < start_date
      errors.add(:end_date, "deve ser igual ou posterior à data inicial")
    end
  end

  def end_time_after_start_time_if_present
    return unless start_time.present? && end_time.present?
    return if start_date != end_date

    if end_time.strftime("%H:%M") <= start_time.strftime("%H:%M")
      errors.add(:end_time, "deve ser posterior ao horário inicial")
    end
  end

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

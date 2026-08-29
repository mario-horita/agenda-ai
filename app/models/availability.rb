class Availability < ApplicationRecord
  self.implicit_order_column = :created_at

  DAYS = {
    0 => "Domingo",
    1 => "Segunda-feira",
    2 => "Terça-feira",
    3 => "Quarta-feira",
    4 => "Quinta-feira",
    5 => "Sexta-feira",
    6 => "Sábado"
  }.freeze

  # === Associations ===
  belongs_to :professional

  # === Validations ===
  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validates :professional_id, uniqueness: { scope: [ :day_of_week, :start_time ], message: "já possui este horário configurado para este dia" }

  # === Callbacks ===
  before_create :generate_id

  # === Scopes ===
  scope :for_day, ->(day) { where(day_of_week: day).order(:start_time) }
  scope :ordered, -> { order(:day_of_week, :start_time) }

  # === Helpers ===
  def day_name
    DAYS[day_of_week]
  end

  def formatted_start_time
    start_time.strftime("%H:%M") if start_time
  end

  def formatted_end_time
    end_time.strftime("%H:%M") if end_time
  end

  def time_range
    "#{formatted_start_time} às #{formatted_end_time}"
  end

  private

  def end_time_after_start_time
    return unless start_time.present? && end_time.present?

    if end_time.strftime("%H:%M") <= start_time.strftime("%H:%M")
      errors.add(:end_time, "deve ser posterior ao horário inicial")
    end
  end

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

class Appointment < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Multi-Tenancy ===
  acts_as_tenant :tenant

  # === Associations ===
  belongs_to :tenant
  belongs_to :professional
  belongs_to :service
  belongs_to :client, counter_cache: true
  has_many :notifications, dependent: :destroy

  # === Enums ===
  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    completed: "completed",
    cancelled: "cancelled",
    no_show: "no_show"
  }, prefix: true

  enum :cancelled_by, {
    client: "client",
    admin: "admin",
    professional: "professional"
  }, prefix: :cancelled_by

  # === Validations ===
  validates :starts_at, :ends_at, presence: true
  validates :status, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validate :ends_at_after_starts_at

  # === Scopes ===
  scope :active, -> { where(status: [ :pending, :confirmed ]) }
  scope :overlapping, ->(start_time, end_time) {
    where("starts_at < ? AND ends_at > ?", end_time, start_time)
  }
  scope :for_date, ->(date) {
    where(starts_at: date.beginning_of_day..date.end_of_day)
  }
  scope :chronological, -> { order(:starts_at) }

  # === Callbacks ===
  before_create :generate_id

  # === Helpers ===
  def price_in_reais
    price_cents / 100.0
  end

  def formatted_time
    "#{starts_at.strftime('%H:%M')} - #{ends_at.strftime('%H:%M')}"
  end

  private

  def ends_at_after_starts_at
    return unless starts_at.present? && ends_at.present?

    if ends_at <= starts_at
      errors.add(:ends_at, "deve ser posterior ao horário de início")
    end
  end

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

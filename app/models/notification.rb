class Notification < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Associations ===
  belongs_to :appointment

  # === Enums ===
  enum :channel, {
    email: "email",
    whatsapp: "whatsapp"
  }, prefix: :channel

  enum :notification_type, {
    confirmation: "confirmation",
    reminder_24h: "reminder_24h",
    reminder_2h: "reminder_2h",
    cancellation: "cancellation",
    reschedule: "reschedule"
  }, prefix: :type

  enum :status, {
    pending: "pending",
    sent: "sent",
    failed: "failed"
  }, prefix: :status

  # === Validations ===
  validates :channel, :notification_type, :status, presence: true

  # === Callbacks ===
  before_create :generate_id

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

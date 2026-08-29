class TenantSetting < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Associations ===
  belongs_to :tenant

  # === Validations ===
  validates :cancellation_window_hours, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reminder_hours, presence: true, numericality: { greater_than: 0 }
  validates :notification_channels, presence: true

  # === Callbacks ===
  before_create :generate_id

  def notification_channels_array
    return [] if notification_channels.blank?

    if notification_channels.is_a?(Array)
      notification_channels.reject(&:blank?)
    else
      notification_channels.to_s.split(",").map(&:strip).reject(&:blank?)
    end
  end

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

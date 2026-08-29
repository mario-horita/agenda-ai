class ProfessionalService < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Associations ===
  belongs_to :professional
  belongs_to :service

  # === Validations ===
  validates :professional_id, uniqueness: { scope: :service_id }

  # === Callbacks ===
  before_create :generate_id

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

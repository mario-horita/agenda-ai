class User < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Devise ===
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  # === Multi-Tenancy ===
  acts_as_tenant :tenant

  # === Associations ===
  belongs_to :tenant

  # === Validations ===
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin manager] }

  # === Enums ===
  enum :role, { admin: "admin", manager: "manager" }, prefix: true

  # === Callbacks ===
  before_create :generate_id

  # === API Tokens ===
  def generate_api_token(expires_in = 90.days)
    Rails.application.message_verifier(:api_token).generate(
      { user_id: id, tenant_id: tenant_id },
      expires_in: expires_in,
      purpose: :api_access
    )
  end

  def self.find_by_api_token(token)
    data = Rails.application.message_verifier(:api_token).verify(token, purpose: :api_access)
    return nil unless data.is_a?(Hash) && data[:user_id].present?

    find_by(id: data[:user_id], tenant_id: data[:tenant_id])
  rescue StandardError
    nil
  end

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

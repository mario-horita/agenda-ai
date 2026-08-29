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

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

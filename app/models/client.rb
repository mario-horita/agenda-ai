class Client < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Multi-Tenancy ===
  acts_as_tenant :tenant

  # === Associations ===
  belongs_to :tenant
  has_many :appointments, dependent: :destroy

  # === Validations ===
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # === Callbacks ===
  before_create :generate_id

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

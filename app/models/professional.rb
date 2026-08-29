class Professional < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Multi-Tenancy ===
  acts_as_tenant :tenant

  # === Associations ===
  belongs_to :tenant
  has_many :professional_services, dependent: :destroy
  has_many :services, through: :professional_services
  has_many :availabilities, dependent: :destroy
  has_many :time_blocks, dependent: :destroy
  has_many :appointments, dependent: :destroy

  # === Validations ===
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :buffer_minutes, numericality: { greater_than_or_equal_to: 0 }

  # === Scopes ===
  scope :active, -> { where(active: true) }

  # === Callbacks ===
  before_create :generate_id

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

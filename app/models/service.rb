class Service < ApplicationRecord
  self.implicit_order_column = :created_at

  # === Multi-Tenancy ===
  acts_as_tenant :tenant

  # === Associations ===
  belongs_to :tenant
  has_many :professional_services, dependent: :destroy
  has_many :professionals, through: :professional_services
  has_many :appointments, dependent: :destroy

  # === Validations ===
  validates :name, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true

  # === Scopes ===
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :name) }

  # === Callbacks ===
  before_create :generate_id

  # === Helpers ===
  def price_in_reais
    price_cents / 100.0
  end

  def price_in_reais=(value)
    self.price_cents = (value.to_f * 100).round
  end

  def formatted_price
    ActionController::Base.helpers.number_to_currency(
      price_in_reais,
      unit: "R$",
      separator: ",",
      delimiter: "."
    )
  end

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end

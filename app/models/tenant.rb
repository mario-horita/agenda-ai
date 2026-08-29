class Tenant < ApplicationRecord
  self.implicit_order_column = :created_at

  PLANS = {
    "starter" => { name: "Starter", price_cents: 7900, price_reais: 79.00, max_professionals: 1, features: [ "1 Profissional", "Até 100 agendamentos/mês", "Notificações por Email", "Página pública personalizada" ] },
    "pro" => { name: "Pro", price_cents: 14900, price_reais: 149.00, max_professionals: 5, features: [ "Até 5 Profissionais", "Agendamentos Ilimitados", "Notificações por Email & WhatsApp", "Métricas & Relatórios de Negócio", "Gestão de Bloqueios" ] },
    "enterprise" => { name: "Enterprise", price_cents: 29900, price_reais: 299.00, max_professionals: 999, features: [ "Profissionais Ilimitados", "Agendamentos Ilimitados", "WhatsApp & SMS prioritário", "Suporte Dedicado 24/7", "Multi-unidades" ] }
  }.freeze

  # === Associations ===
  has_many :users, dependent: :destroy
  has_many :professionals, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_one :tenant_setting, dependent: :destroy

  # === Validations ===
  validates :name, presence: true
  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-z0-9\-]+\z/, message: "deve conter apenas letras minúsculas, números e hífens" },
                   length: { minimum: 3, maximum: 63 }
  validates :plan, presence: true, inclusion: { in: %w[starter pro enterprise] }
  validates :timezone, presence: true

  # === Enums ===
  enum :plan, { starter: "starter", pro: "pro", enterprise: "enterprise" }, prefix: true
  attribute :subscription_status, :string, default: "trialing"
  enum :subscription_status, {
    trialing: "trialing",
    active: "active",
    past_due: "past_due",
    canceled: "canceled",
    unpaid: "unpaid"
  }, prefix: :subscription

  # === Callbacks ===
  before_validation :normalize_slug
  before_create :generate_id
  after_create :create_default_settings

  # === Helper Methods ===
  def on_trial?
    trial_ends_at.present? && trial_ends_at.to_date >= Date.current && subscription_trialing?
  end

  def subscribed?
    subscription_active?
  end

  def has_active_access?
    subscribed? || on_trial?
  end

  def trial_days_left
    return 0 unless on_trial?

    (trial_ends_at.to_date - Date.current).to_i
  end

  def max_professionals
    PLANS.dig(plan, :max_professionals) || 1
  end

  def plan_details
    PLANS[plan] || PLANS["starter"]
  end

  private

  def normalize_slug
    self.slug = slug.to_s.downcase.strip if slug.present?
  end

  def generate_id
    self.id ||= SecureRandom.uuid
  end

  def create_default_settings
    create_tenant_setting! unless tenant_setting
  end
end

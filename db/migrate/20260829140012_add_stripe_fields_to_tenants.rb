class AddStripeFieldsToTenants < ActiveRecord::Migration[8.0]
  def change
    add_column :tenants, :stripe_customer_id, :string
    add_column :tenants, :stripe_subscription_id, :string
    add_column :tenants, :subscription_status, :string, default: "trialing", null: false
    add_column :tenants, :current_period_end, :datetime

    add_index :tenants, :stripe_customer_id
    add_index :tenants, :stripe_subscription_id
    add_index :tenants, :subscription_status
  end
end

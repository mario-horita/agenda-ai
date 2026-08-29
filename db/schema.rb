# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_29_140012) do
  create_table "appointments", id: :string, force: :cascade do |t|
    t.string "cancellation_reason"
    t.datetime "cancelled_at"
    t.string "cancelled_by"
    t.string "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "price_cents", default: 0, null: false
    t.string "professional_id", null: false
    t.string "service_id", null: false
    t.datetime "starts_at", null: false
    t.string "status", default: "confirmed", null: false
    t.string "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_appointments_on_client_id"
    t.index ["professional_id", "starts_at", "status"], name: "index_appointments_on_professional_id_and_starts_at_and_status"
    t.index ["tenant_id", "starts_at"], name: "index_appointments_on_tenant_id_and_starts_at"
    t.index ["tenant_id", "status"], name: "index_appointments_on_tenant_id_and_status"
  end

  create_table "availabilities", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.string "professional_id", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id", "day_of_week", "start_time"], name: "idx_availabilities_prof_day_start", unique: true
    t.index ["professional_id", "day_of_week"], name: "index_availabilities_on_professional_id_and_day_of_week"
  end

  create_table "clients", id: :string, force: :cascade do |t|
    t.integer "appointments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "last_appointment_at"
    t.string "name", null: false
    t.integer "no_show_count", default: 0, null: false
    t.string "phone"
    t.string "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "email"], name: "index_clients_on_tenant_id_and_email"
    t.index ["tenant_id", "phone"], name: "index_clients_on_tenant_id_and_phone"
    t.index ["tenant_id"], name: "index_clients_on_tenant_id"
  end

  create_table "notifications", id: :string, force: :cascade do |t|
    t.string "appointment_id", null: false
    t.string "channel", default: "email", null: false
    t.datetime "created_at", null: false
    t.text "metadata"
    t.string "notification_type", null: false
    t.datetime "scheduled_for"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_notifications_on_appointment_id"
    t.index ["status", "scheduled_for"], name: "index_notifications_on_status_and_scheduled_for"
  end

  create_table "professional_services", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "professional_id", null: false
    t.string "service_id", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id", "service_id"], name: "index_professional_services_on_professional_id_and_service_id", unique: true
    t.index ["service_id"], name: "index_professional_services_on_service_id"
  end

  create_table "professionals", id: :string, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "avatar_url"
    t.text "bio"
    t.integer "buffer_minutes", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.string "phone"
    t.string "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "active"], name: "index_professionals_on_tenant_id_and_active"
    t.index ["tenant_id"], name: "index_professionals_on_tenant_id"
  end

  create_table "services", id: :string, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "BRL", null: false
    t.text "description"
    t.integer "duration_minutes", null: false
    t.string "name", null: false
    t.integer "price_cents", default: 0, null: false
    t.integer "sort_order", default: 0, null: false
    t.string "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "active"], name: "index_services_on_tenant_id_and_active"
    t.index ["tenant_id"], name: "index_services_on_tenant_id"
  end

  create_table "tenant_settings", id: :string, force: :cascade do |t|
    t.boolean "allow_reschedule", default: true, null: false
    t.text "booking_page_config"
    t.integer "cancellation_window_hours", default: 24, null: false
    t.datetime "created_at", null: false
    t.string "notification_channels", default: "email", null: false
    t.integer "reminder_hours", default: 24, null: false
    t.string "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_tenant_settings_on_tenant_id", unique: true
  end

  create_table "tenants", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.string "logo_url"
    t.string "name", null: false
    t.string "phone"
    t.string "plan", default: "starter", null: false
    t.string "primary_color", default: "#6366f1"
    t.string "secondary_color", default: "#8b5cf6"
    t.string "slug", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "subscription_status", default: "trialing", null: false
    t.string "timezone", default: "America/Sao_Paulo", null: false
    t.date "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tenants_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_tenants_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_tenants_on_stripe_subscription_id"
    t.index ["subscription_status"], name: "index_tenants_on_subscription_status"
  end

  create_table "time_blocks", id: :string, force: :cascade do |t|
    t.boolean "all_day", default: false, null: false
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.time "end_time"
    t.string "professional_id", null: false
    t.string "reason", null: false
    t.date "start_date", null: false
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.index ["professional_id", "start_date", "end_date"], name: "idx_on_professional_id_start_date_end_date_49b6805266"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "admin", null: false
    t.string "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "appointments", "clients"
  add_foreign_key "appointments", "professionals"
  add_foreign_key "appointments", "services"
  add_foreign_key "appointments", "tenants"
  add_foreign_key "availabilities", "professionals"
  add_foreign_key "clients", "tenants"
  add_foreign_key "notifications", "appointments"
  add_foreign_key "professional_services", "professionals"
  add_foreign_key "professional_services", "services"
  add_foreign_key "professionals", "tenants"
  add_foreign_key "services", "tenants"
  add_foreign_key "tenant_settings", "tenants"
  add_foreign_key "time_blocks", "professionals"
  add_foreign_key "users", "tenants"
end

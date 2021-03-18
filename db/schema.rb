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

ActiveRecord::Schema.define(version: 2021_03_18_181636) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "balance", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "merchant_id", null: false
    t.index ["merchant_id"], name: "index_accounts_on_merchant_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "type", null: false
    t.integer "amount"
    t.bigint "account_id"
    t.string "customer_email"
    t.string "customer_phone"
    t.string "notification_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "unique_id", null: false
    t.integer "status", null: false
    t.json "validation_errors"
    t.integer "notification"
    t.datetime "last_notification_at"
    t.integer "notification_attempts", default: 0
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["uuid"], name: "index_transactions_on_uuid"
  end

  create_table "users", force: :cascade do |t|
    t.string "type", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts", "users", column: "merchant_id"
  add_foreign_key "transactions", "accounts"
end

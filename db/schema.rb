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

ActiveRecord::Schema.define(version: 2021_07_17_062019) do

  create_table "referenced_registrations", force: :cascade do |t|
    t.integer "referer_id", null: false
    t.integer "user_id", null: false
    t.boolean "checked", default: false
    t.index ["referer_id"], name: "index_referenced_registrations_on_referer_id"
    t.index ["user_id"], name: "index_referenced_registrations_on_user_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.string "code", null: false
    t.integer "user_id", null: false
    t.index ["code"], name: "index_referrals_on_code", unique: true
    t.index ["user_id"], name: "index_referrals_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "referenced_registrations", "users"
  add_foreign_key "referenced_registrations", "users", column: "referer_id"
end

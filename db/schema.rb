# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150914060733) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", unique: true, using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "choices", force: :cascade do |t|
    t.integer  "poll_id",                 null: false
    t.string   "value",                   null: false
    t.integer  "votes_count", default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "choices", ["poll_id", "value"], name: "index_choices_on_poll_id_and_value", unique: true, using: :btree
  add_index "choices", ["poll_id"], name: "index_choices_on_poll_id", using: :btree

  create_table "polls", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "polls", ["content"], name: "index_polls_on_content", unique: true, using: :btree
  add_index "polls", ["user_id"], name: "index_polls_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                              null: false
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.string   "reset_digest"
    t.boolean  "admin",             default: false
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.datetime "reset_sent_at"
    t.string   "image_url"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "choice_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "votes", ["choice_id"], name: "index_votes_on_choice_id", using: :btree
  add_index "votes", ["user_id", "choice_id"], name: "index_votes_on_user_id_and_choice_id", unique: true, using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

  add_foreign_key "authentications", "users", on_delete: :cascade
  add_foreign_key "choices", "polls", on_delete: :cascade
  add_foreign_key "polls", "users", on_delete: :cascade
  add_foreign_key "votes", "choices", on_delete: :cascade
  add_foreign_key "votes", "users", on_delete: :cascade
end

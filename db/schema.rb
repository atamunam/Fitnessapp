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

ActiveRecord::Schema.define(version: 20141211123702) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "challenges", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competitor_id"
  end

  create_table "user_challenges", force: true do |t|
    t.integer  "user_id"
    t.integer  "competitor_id"
    t.boolean  "is_approved"
    t.boolean  "is_completed"
    t.boolean  "is_accepted"
    t.boolean  "is_winner"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "challenge_id"
  end

  create_table "user_sessions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points"
    t.integer  "points_at_stake"
  end

end

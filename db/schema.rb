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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120212235654) do

  create_table "cities", :force => true do |t|
    t.string   "name",       :null => false
    t.decimal  "latitude",   :null => false
    t.decimal  "longitude",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drives", :force => true do |t|
    t.integer  "seats",               :default => 1, :null => false
    t.integer  "free_seats"
    t.date     "date",                               :null => false
    t.integer  "user_id",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "start_city_id",                      :null => false
    t.integer  "destination_city_id",                :null => false
    t.text     "comment"
    t.integer  "distance"
    t.decimal  "cost"
    t.string   "currency"
  end

  create_table "messages", :force => true do |t|
    t.string   "title",                           :null => false
    t.string   "contents",                        :null => false
    t.integer  "sender_id",                       :null => false
    t.integer  "recipient_id",                    :null => false
    t.boolean  "is_read",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mid_locations", :force => true do |t|
    t.integer  "drive_id",                  :null => false
    t.integer  "city_id",                   :null => false
    t.integer  "order",      :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name",                                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthdate"
    t.string   "phone_number"
    t.string   "alt_email"
    t.string   "show_email"
    t.string   "show_alt_email"
    t.string   "show_phone_number"
    t.string   "show_hometown"
    t.integer  "hometown_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

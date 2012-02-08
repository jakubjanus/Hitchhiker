ActiveRecord::Schema.define(:version => 20111204191913) do

  create_table "cities", :force => true do |t|
    t.string   "name",       :null => false
    t.decimal  "latitude",   :null => false
    t.decimal  "longitude",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drives", :force => true do |t|
    t.integer  "seats",               :default => 1,    :null => false
    t.integer  "free_seats"
    t.date     "date",                                  :null => false
    t.boolean  "is_up_to_date",       :default => true, :null => false
    t.integer  "user_id",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "start_city_id",                         :null => false
    t.integer  "destination_city_id",                   :null => false
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
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

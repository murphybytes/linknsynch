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

ActiveRecord::Schema.define(:version => 20140406210559) do

  create_table "calculations", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "user_id"
    t.integer "set_meta_id"
    t.integer "node_id"
  end

  create_table "calculations_home_profiles", :id => false, :force => true do |t|
    t.integer "calculation_id"
    t.integer "home_profile_id"
  end

  add_index "calculations_home_profiles", ["calculation_id", "home_profile_id"], :name => "chp_index"

  create_table "calculations_thermal_storage_profiles", :id => false, :force => true do |t|
    t.integer "calculation_id"
    t.integer "thermal_storage_profile_id"
  end

  add_index "calculations_thermal_storage_profiles", ["calculation_id", "thermal_storage_profile_id"], :name => "ctsp_index"

  create_table "holidays", :force => true do |t|
    t.string   "name"
    t.date     "occurance"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "home_profiles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "home_count"
    t.integer  "user_id"
    t.decimal  "btu_factor"
    t.integer  "base_temperature"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "thermostat_temperature"
    t.integer  "priority"
  end

  create_table "location_marginal_prices", :force => true do |t|
    t.datetime "period"
    t.decimal  "value"
    t.integer  "node_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "location_marginal_prices", ["period"], :name => "index_location_marginal_prices_on_period"

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.string   "node_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "nodes", ["name"], :name => "index_nodes_on_name"
  add_index "nodes", ["node_type"], :name => "index_nodes_on_node_type"

  create_table "samples", :force => true do |t|
    t.integer  "set_meta_id"
    t.datetime "sample_time"
    t.integer  "generated_kilowatts"
    t.integer  "temperature"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "samples", ["sample_time"], :name => "index_samples_on_sample_time"
  add_index "samples", ["set_meta_id"], :name => "index_samples_on_set_meta_id"

  create_table "set_meta", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
  end

  create_table "thermal_storage_profiles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "units"
    t.integer  "user_id"
    t.decimal  "capacity"
    t.decimal  "storage"
    t.decimal  "charge_rate"
    t.decimal  "base_threshold"
    t.decimal  "usage"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "priority"
    t.integer  "water_heat_flag"
    t.integer  "base_temperature"
    t.integer  "thermostat_temperature"
    t.decimal  "btu_factor"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

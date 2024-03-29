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

ActiveRecord::Schema.define(:version => 20130909000457) do

  create_table "fen_moves", :force => true do |t|
    t.integer  "reference_database_id"
    t.string   "move"
    t.integer  "white"
    t.integer  "black"
    t.integer  "draw"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "games", :force => true do |t|
    t.integer  "white_id"
    t.integer  "black_id"
    t.integer  "pgn_file_id"
    t.string   "annotator"
    t.float    "white_avg_error"
    t.float    "black_avg_error"
    t.integer  "tournament_id"
    t.integer  "site_id"
    t.datetime "start_date"
    t.integer  "round"
    t.string   "result"
    t.integer  "status"
    t.datetime "end_date"
    t.float    "white_std_deviation"
    t.float    "black_std_deviation"
    t.float    "white_perfect_rate"
    t.float    "black_perfect_rate"
    t.float    "black_blunder_rate"
    t.float    "white_blunder_rate"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.float    "progress"
    t.float    "tie_threshold"
    t.float    "blunder_threshold"
    t.string   "player_out_db_ref"
    t.integer  "move_out_db_ref"
    t.decimal  "value_out_db_ref"
    t.decimal  "best_value_out_db_ref"
    t.decimal  "deviation_out_db_ref"
    t.string   "white_elo"
    t.string   "black_elo"
    t.float    "total_average_error"
    t.float    "total_perfect_rate"
  end

  create_table "moves", :force => true do |t|
    t.boolean  "side"
    t.string   "pgn"
    t.string   "lan"
    t.float    "player_value"
    t.string   "annotator_move"
    t.float    "annotator_value"
    t.integer  "number"
    t.integer  "status"
    t.text     "comments"
    t.boolean  "check"
    t.boolean  "mate"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "game_id"
    t.float    "distance"
  end

  create_table "pgn_files", :force => true do |t|
    t.string   "description"
    t.string   "pgn_file"
    t.integer  "status"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.float    "average_distance"
    t.float    "average_perfect"
    t.integer  "time"
    t.float    "tie_threshold"
    t.float    "blunder_threshold"
    t.integer  "ref_db_id"
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reference_databases", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tournaments", :force => true do |t|
    t.string   "name"
    t.integer  "site_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
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
    t.string   "authentication_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

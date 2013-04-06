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

ActiveRecord::Schema.define(:version => 20130405180115) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_functions", :force => true do |t|
    t.integer "category_id"
    t.integer "function_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",                 :default => 0
    t.string   "commentable_type", :limit => 15, :default => ""
    t.string   "title",                          :default => ""
    t.text     "body",                           :default => ""
    t.string   "subject",                        :default => ""
    t.integer  "user_id",                        :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "example_versions", :force => true do |t|
    t.integer  "example_id"
    t.integer  "version"
    t.text     "body"
    t.integer  "function_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "example_versions", ["example_id"], :name => "index_example_versions_on_example_id"

  create_table "examples", :force => true do |t|
    t.text     "body"
    t.integer  "examplable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "user_id"
    t.string   "examplable_type"
    t.string   "name"
    t.text     "doc"
    t.text     "output"
  end

  add_index "examples", ["examplable_id"], :name => "function_id_idx"

  create_table "function_references", :id => false, :force => true do |t|
    t.integer "from_function_id"
    t.integer "to_function_id"
  end

  create_table "functions", :force => true do |t|
    t.string   "name"
    t.string   "file"
    t.string   "line"
    t.text     "arglists_comp"
    t.string   "added"
    t.text     "doc"
    t.text     "source"
    t.integer  "weight",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shortdoc"
    t.string   "version"
    t.string   "url_friendly_name"
    t.integer  "functional_id"
    t.tsvector "search_vector"
    t.string   "functional_type"
  end

  add_index "functions", ["functional_id"], :name => "namespace_id_idx"
  add_index "functions", ["search_vector"], :name => "functions_search_idx"

  create_table "libraries", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "site_url"
    t.string   "source_base_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "copyright"
    t.string   "license"
    t.string   "version"
    t.boolean  "current"
    t.string   "url_friendly_name"
  end

  create_table "library_import_logs", :force => true do |t|
    t.string   "library_import_task_id"
    t.string   "level"
    t.text     "message"
    t.datetime "created_at",             :null => false
  end

  create_table "library_import_tasks", :force => true do |t|
    t.integer  "library_id"
    t.integer  "vars_found"
    t.integer  "references_found"
    t.integer  "vars_removed"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "namespaces", :force => true do |t|
    t.string   "name"
    t.text     "doc"
    t.string   "source_url"
    t.string   "repo_host"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
    t.integer  "library_id"
  end

  add_index "namespaces", ["library_id"], :name => "library_id_idx"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "pg_search_documents", :force => true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "remarks", :force => true do |t|
    t.integer  "user_id"
    t.string   "source_url"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "see_alsos", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "user_id"
    t.integer  "weight",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "see_alsos", ["from_id"], :name => "from_id_idx"
  add_index "see_alsos", ["to_id"], :name => "to_id_idx"

  create_table "type_classes", :force => true do |t|
    t.string   "name"
    t.integer  "namespace_id"
    t.text     "doc"
    t.string   "source_url"
    t.text     "arglists_comp"
    t.string   "version"
    t.string   "type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "shortdoc"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count",            :default => 0,  :null => false
    t.integer  "failed_login_count",     :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_url"
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["identity_url"], :name => "index_users_on_identity_url", :unique => true
  add_index "users", ["identity_url"], :name => "index_users_on_openid_identifier"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.boolean  "vote",                        :default => false
    t.datetime "created_at",                                     :null => false
    t.string   "voteable_type", :limit => 15, :default => "",    :null => false
    t.integer  "voteable_id",                 :default => 0,     :null => false
    t.integer  "user_id",                     :default => 0,     :null => false
  end

  add_index "votes", ["user_id"], :name => "fk_votes_user"

end

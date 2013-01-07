# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110926024801) do

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",                 :default => 0
    t.string   "commentable_type", :limit => 15
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",                        :default => 0, :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "example_versions", :force => true do |t|
    t.integer  "example_id"
    t.integer  "version"
    t.text     "body"
    t.integer  "function_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "examples", :force => true do |t|
    t.text     "body"
    t.integer  "function_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "user_id"
  end

  create_table "flat_comments_view", :id => false, :force => true do |t|
    t.integer  "id",                             :default => 0, :null => false
    t.integer  "commentable_id",                 :default => 0
    t.string   "commentable_type", :limit => 15
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",                        :default => 0, :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "library"
    t.string   "version"
    t.string   "ns"
    t.string   "function"
    t.integer  "library_id",                     :default => 0
    t.integer  "namespace_id",                   :default => 0
  end

  create_table "flat_examples_view", :id => false, :force => true do |t|
    t.integer  "id",           :default => 0, :null => false
    t.text     "body"
    t.integer  "function_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "user_id"
    t.string   "library"
    t.string   "lib_version"
    t.string   "ns"
    t.string   "function"
    t.integer  "library_id",   :default => 0
    t.integer  "namespace_id", :default => 0
  end

  create_table "flat_functions_view", :id => false, :force => true do |t|
    t.integer  "id",                              :default => 0, :null => false
    t.string   "name"
    t.string   "file"
    t.string   "line"
    t.string   "arglists_comp"
    t.string   "added"
    t.text     "doc"
    t.text     "source"
    t.integer  "weight",                          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shortdoc",          :limit => 70
    t.string   "version"
    t.string   "url_friendly_name"
    t.integer  "namespace_id"
    t.string   "library"
    t.string   "ns"
    t.integer  "library_id",                      :default => 0
  end

  create_table "flat_see_alsos_view", :id => false, :force => true do |t|
    t.integer  "id",           :default => 0, :null => false
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "user_id"
    t.integer  "weight",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "library"
    t.string   "version"
    t.string   "ns"
    t.string   "function"
    t.integer  "library_id",   :default => 0
    t.integer  "namespace_id", :default => 0
  end

  create_table "function_references", :id => false, :force => true do |t|
    t.integer "from_function_id"
    t.integer "to_function_id"
  end

  create_table "functions", :force => true do |t|
    t.string   "name"
    t.string   "file"
    t.string   "line"
    t.string   "arglists_comp"
    t.string   "added"
    t.text     "doc"
    t.text     "source"
    t.integer  "weight",                          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shortdoc",          :limit => 70
    t.string   "version"
    t.string   "url_friendly_name"
    t.integer  "namespace_id"
  end

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

  create_table "see_alsos", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "user_id"
    t.integer  "weight",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email",                             :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                 :null => false
    t.integer  "login_count",        :default => 0, :null => false
    t.integer  "failed_login_count", :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "openid_identifier"
  end

  create_table "votes", :force => true do |t|
    t.boolean  "vote",                        :default => false
    t.datetime "created_at",                                     :null => false
    t.string   "voteable_type", :limit => 15,                    :null => false
    t.integer  "voteable_id",                 :default => 0,     :null => false
    t.integer  "user_id",                     :default => 0,     :null => false
  end

end

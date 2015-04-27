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

ActiveRecord::Schema.define(version: 20150317165802) do

  create_table "activities", force: true do |t|
    t.integer  "user_id"
    t.string   "verb"
    t.integer  "link_request_id"
    t.integer  "ip_id"
    t.text     "notes"
    t.datetime "occurred"
  end

  create_table "approvals", force: true do |t|
    t.integer  "ip_id"
    t.string   "status",          default: "PENDING"
    t.integer  "approved_by_id"
    t.date     "approved_at"
    t.integer  "link_request_id"
    t.integer  "owner_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "controller_command_stacks", force: true do |t|
    t.text     "command"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ips", force: true do |t|
    t.string   "addr"
    t.integer  "subnet_id"
    t.integer  "vlan_id"
    t.string   "fqdn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link_requests", force: true do |t|
    t.integer  "user_id"
    t.text     "comment"
    t.integer  "duration"
    t.date     "start"
    t.date     "end"
    t.integer  "traffic",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "net_config_transactions", force: true do |t|
    t.string   "who"
    t.string   "description"
    t.string   "target"
    t.text     "command"
    t.string   "status"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "owner_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "owner_groups_users", id: false, force: true do |t|
    t.integer "owner_group_id"
    t.integer "user_id"
  end

  add_index "owner_groups_users", ["owner_group_id"], name: "index_owner_groups_users_on_owner_group_id", using: :btree
  add_index "owner_groups_users", ["user_id"], name: "index_owner_groups_users_on_user_id", using: :btree

  create_table "owner_objects", force: true do |t|
    t.integer  "owner_group_id"
    t.integer  "ownable_id"
    t.string   "ownable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subnets", force: true do |t|
    t.string   "cidr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "switch_connection_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "switch_initial_configs", force: true do |t|
    t.string   "ip"
    t.string   "vlan"
    t.integer  "switch_connection_type_id"
    t.integer  "switch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "switches", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "hub"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "netid"
    t.string   "duid"
    t.string   "displayName"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["duid"], name: "index_users_on_duid", unique: true, using: :btree
  add_index "users", ["netid"], name: "index_users_on_netid", unique: true, using: :btree

  create_table "vlans", force: true do |t|
    t.string   "vlan_name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

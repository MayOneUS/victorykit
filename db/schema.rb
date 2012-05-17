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

ActiveRecord::Schema.define(:version => 20120517143836) do

  create_table "bounced_emails", :force => true do |t|
    t.text     "raw_content"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "sent_email_id", :null => false
  end

  create_table "last_updated_unsubscribes", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "is_locked",  :null => false
  end

  create_table "mailer_process_trackers", :force => true do |t|
    t.boolean  "is_locked"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "members", ["email"], :name => "index_members_on_email", :unique => true

  create_table "petitions", :force => true do |t|
    t.text     "title",                          :null => false
    t.text     "description",                    :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "owner_id"
    t.boolean  "to_send",     :default => false
  end

  create_table "sent_emails", :force => true do |t|
    t.string   "email",        :null => false
    t.integer  "member_id",    :null => false
    t.integer  "petition_id",  :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "signature_id"
  end

  create_table "signatures", :force => true do |t|
    t.string   "name",           :null => false
    t.string   "email",          :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "petition_id",    :null => false
    t.string   "ip_address",     :null => false
    t.string   "user_agent",     :null => false
    t.string   "browser_name"
    t.boolean  "created_member"
    t.integer  "member_id",      :null => false
  end

  create_table "unsubscribes", :force => true do |t|
    t.string   "email",         :null => false
    t.string   "cause"
    t.integer  "member_id",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "ip_address"
    t.string   "user_agent"
    t.integer  "sent_email_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "password_digest",                    :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "is_super_user",   :default => false, :null => false
    t.boolean  "is_admin",        :default => false, :null => false
  end

  add_foreign_key "bounced_emails", "sent_emails", :name => "bounced_emails_sent_email_id_fk"

  add_foreign_key "petitions", "users", :name => "petitions_owner_id_fk", :column => "owner_id"

  add_foreign_key "sent_emails", "members", :name => "sent_emails_member_id_fk"
  add_foreign_key "sent_emails", "signatures", :name => "sent_emails_signature_id_fk"

  add_foreign_key "signatures", "members", :name => "signatures_member_id_fk"
  add_foreign_key "signatures", "petitions", :name => "signatures_petition_id_fk"

  add_foreign_key "unsubscribes", "members", :name => "unsubscribes_member_id_fk"
  add_foreign_key "unsubscribes", "sent_emails", :name => "unsubscribes_sent_email_id_fk"

end

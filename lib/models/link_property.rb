# coding: UTF-8

require 'sequel'

class LinkProperty < Sequel::Model
  many_to_one :link
  set_schema do
    primary_key :id
    foreign_key :link_id, :links
    String :key, :null=>false
    String :value, :null=>false
    index [:link_id, :key], :unique=>true
  end
end

LinkProperty.create_table unless LinkProperty.table_exists?

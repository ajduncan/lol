# coding: UTF-8

require 'sequel'

class ItemProperty < Sequel::Model
  many_to_one :item
  set_schema do
    primary_key :id
    foreign_key :item_id, :items
    string :key, :null=>false
    string :value, :null=>false
    index [:item_id, :key], :unique=>true
  end
end

ItemProperty.create_table unless ItemProperty.table_exists?

# coding: UTF-8

require 'sequel'

class ItemProperty < Sequel::Model
  many_to_one :item
end

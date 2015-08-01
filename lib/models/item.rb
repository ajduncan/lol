# coding: UTF-8

require 'sequel'

class Item < Sequel::Model
  plugin :validation_helpers
  one_to_many :item_properties

  def validate
    super
    validates_presence [:name]
  end
end

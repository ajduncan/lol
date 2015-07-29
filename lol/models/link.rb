# coding: UTF-8

require 'sequel'

class Link < Sequel::Model
  plugin :validation_helpers
  one_to_many :link_properties

  def validate
    super
    validates_presence [:name]
  end
end

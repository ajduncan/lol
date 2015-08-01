# coding: UTF-8

require 'sequel'

class LinkProperty < Sequel::Model
  many_to_one :link
end

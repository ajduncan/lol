# coding: UTF-8

require 'sequel'

class Link < Sequel::Model
  plugin :validation_helpers
  one_to_many :link_properties
  one_to_one :src_item, :class => :Item, :key => :id
  one_to_one :dst_item, :class => :Item, :key => :id

  def validate
    super
    validates_presence [:name]
  end

  def self.print_exits(location)
    exits = where(:src_item_id => location.id)
    print "Exits: "
    print exits.map{|e| "#{e.name}".blue }.join(', ')
    puts ""
  end

end

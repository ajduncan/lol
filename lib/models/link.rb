# coding: UTF-8

require 'sequel'

# Public: Model for working with links, which reference items.
#
# Examples
#
#   item1 = Item.new(name => 'room1', description => 'a room')
#   item2 = Item.new(name => 'room2', description => 'another room')
#   link = Link.new(src_item => item1, dst_item => item2, name => 'a link from item1 to item2')
#
class Link < Sequel::Model
  plugin :validation_helpers
  one_to_many :link_properties
  one_to_one :src_item, :class => :Item, :key => :id
  one_to_one :dst_item, :class => :Item, :key => :id
  set_schema do
    primary_key :id
    foreign_key :src_item_id, :items
    foreign_key :dst_item_id, :items
    String :name, :null=>false
  end

  def validate
    super
    validates_presence [:name]
  end

  # Public: class method which prints the name of all exits.
  #
  # location - The location (which is an Item class)
  #
  # Examples
  #
  #   # create a room (foo), with links (exit 1, exit 2) to rooms bar and baz.
  #   foo = Item.new(name => 'foo') unless !Item.where(:name => 'foo').first.nil?
  #   bar = Item.new(name => 'bar') unless !Item.where(:name => 'bar').first.nil?
  #   baz = Item.new(name => 'baz') unless !Item.where(:name => 'baz').first.nil?
  #   exit1 = Link.new(src_item => location, dst_item => bar, name => 'exit 1')
  #   exit2 = Link.new(src_item => location, dst_item => baz, name => 'exit 2')
  #
  #   # print exits, bar and baz
  #   Link.print_exits(foo)
  def self.print_exits(location)
    exits = where(:src_item_id => location.id)
    print "Exits: "
    print exits.map{|e| "#{e.name}".blue }.join(', ')
    puts ""
  end

end

Link.create_table unless Link.table_exists?

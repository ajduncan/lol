# coding: UTF-8

require 'sequel'

# Public: Model for working with items.
#
# Examples
#
#   item1 = Item.new(name => 'room1', description => 'a room')
#
class Item < Sequel::Model
  plugin :validation_helpers
  one_to_many :item_properties

  set_schema do
    primary_key :id
    integer :type, :null=>false, :default=>0
    string :name, :null=>false
    string :description
  end

  def validate
    super
    validates_presence [:name]
  end

  # Public: instance method which returns all exits associated with itself.
  #
  # Examples
  #
  #   # get a collection of exits
  #   # create a room (foo), with links (exit 1, exit 2) to rooms bar and baz.
  #   foo = Item.new(name => 'foo') unless !Item.where(:name => 'foo').first.nil?
  #   bar = Item.new(name => 'bar') unless !Item.where(:name => 'bar').first.nil?
  #   baz = Item.new(name => 'baz') unless !Item.where(:name => 'baz').first.nil?
  #   exit1 = Link.new(src_item => location, dst_item => bar, name => 'exit 1')
  #   exit2 = Link.new(src_item => location, dst_item => baz, name => 'exit 2')
  #   exits = foo.exits
  #
  # Returns the associated exits of the item
  def exits
    return Link.where(:src_item_id => id)
  end

  # Public: instance method which returns a string of all exits.
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
  #   foo.print_exits
  #
  # Returns the associated exits of the item as a string with colors
  def collect_exits
    exits = Link.where(:src_item_id => id)
    return exits.map{|e| "#{e.name}".blue }.join(', ')
  end

end

Item.create_table unless Item.table_exists?

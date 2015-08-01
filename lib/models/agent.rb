# coding: UTF-8

require 'colorize'

require "./lib/models/item"
require "./lib/models/item_property"
require "./lib/models/link"
require "./lib/models/link_property"
require "./lib/command"


# Public: Model for working with links, which reference items.
#
# Examples
#
#   item1 = Item.new(name => 'room1', description => 'a room')
#   item2 = Item.new(name => 'room2', description => 'another room')
#   link = Link.new(src_item => item1, dst_item => item2, name => 'a link from item1 to item2')
#
class Agent < Sequel::Model
  plugin :validation_helpers
  many_to_one :item
  set_schema do
    primary_key :id
    foreign_key :item_id, :items
    string :name, :null=>false
    string :description, :text=>true
  end

  def validate
    super
    validates_presence [:name, :item]
  end

  def look(what = '')
    case what.downcase
    when '', 'here'
      puts self.item.description
      self.item.print_exits
    when 'm', 'me', 's', 'self'
      puts (self.description || "Nothing special.")
    else
      puts "That isn't here to look at."
    end
  end

  def move(direction)
    link = Link.where(:src_item_id => self.item.id, Sequel.function(:lower, :name) => direction.downcase).first
    if !link.nil?
      self.item = Item.where(:id => link.dst_item_id).first
      @exits = Link.where(:src_item_id => self.item.id)
      return true
    else
      return false
    end
  end

  def repl
    @command = Command.new unless !@command.nil?
    @exits = self.item.exits unless !@exits.nil? # Link.where(:src_item_id => self.item.id) unless !@exits.nil?
    print "$ "
    @command.get_command

    # check exits, triggers, etc
    case @command.last.to_s.downcase
    when *@exits.collect{|e| e.name.downcase }
      move(@command.last.to_s)
      look
      return
    end

    case @command.head.to_s.downcase
    when 'l', 'look'
      look(@command.params)
    when 'q', 'quit'
      puts "Quitting."
      exit(1)
    # todo handle spaced exits, go and goto
    when *@exits.collect{|e| e.name.downcase }
      move(@command.head.to_s)
    else
      puts "Unknown command: '#{@command.last.to_s}'"
    end
  end
end

Agent.create_table unless Agent.table_exists?

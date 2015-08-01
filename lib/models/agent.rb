# coding: UTF-8

require 'colorize'

require "./lib/models/item"
require "./lib/models/item_property"
require "./lib/models/link"
require "./lib/models/link_property"
require "./lib/command"


class Agent < Sequel::Model
  plugin :validation_helpers
  many_to_one :item

  def validate
    super
    validates_presence [:name, :item]
  end

  def initialize(location = 1)
    @location = Item.where(:id => location)
    @exits = Link.where(:src_item => @location)
  end

  def look(what = '')
    case what.downcase
    when '', 'here'
      puts self.item.description
      Link.print_exits(self.item)
    when 'm', 'me', 's', 'self'
      puts (@description || "Nothing special.")
    else
      puts "That isn't here to look at."
    end
  end

  def move(direction)
    link = Link.where(:src_item_id => self.item.id, Sequel.function(:lower, :name) => direction.downcase).first
    self.item = Item.where(:id => link.dst_item_id).first
    @exits = Link.where(:src_item_id => self.item.id)
    look
  end

  def repl
    @command = Command.new unless !@command.nil?
    @exits = Link.where(:src_item_id => self.item.id) unless !@exits.nil?
    print "$ "
    @command.get_command

    # check exits, triggers, etc
    case @command.last.to_s.downcase
    when *@exits.collect{|e| e.name.downcase }
      move(@command.last.to_s)
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

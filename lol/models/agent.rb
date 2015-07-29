# coding: UTF-8

require 'colorize'
require 'sequel'
DB = Sequel.connect('sqlite://db/lol.db')

require "./lol/models/item"
require "./lol/models/item_property"
require "./lol/models/link"
require "./lol/models/link_property"
require "./lol/command"


class Agent < Sequel::Model
  plugin :validation_helpers
  one_to_one :item

  def validate
    super
    validates_presence [:name, :item]
  end

  def initialize
    if Item.count == 0
      puts "Run the DB setup/migration utility!"
    end
    # for now, just put the agent in the first room
    @command = Command.new
    @location = Item.first
    @exits = Link.where(:src_item_id => @location.id)
    look
  end

  def exits
    print "Exits: "
    print @exits.map{|e| "#{e.name}".blue }.join(', ')
    puts ""
  end

  def look(what = '')
    case what.downcase
    when '', 'here'
      puts @location.description
      exits
    when 'm', 'me', 's', 'self'
      puts (@description || "Nothing special.")
    else
      puts "That isn't here to look at."
    end
  end

  def move(direction)
    link = Link.where(:src_item_id => @location.id, Sequel.function(:lower, :name) => direction.downcase).first
    @location = Item.where(:id => link.dst_item_id).first
    @exits = Link.where(:src_item_id => @location.id)
    look
  end

  def run_command
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
      puts "Unknown command: '#{@command.head}'"
    end
  end
end

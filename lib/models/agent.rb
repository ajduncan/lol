# coding: UTF-8

require 'colorize'

require "./lib/models/item"
require "./lib/models/item_property"
require "./lib/models/link"
require "./lib/models/link_property"
require "./lib/command"


# Public: Model for working with agents.
#
# Examples
#
#   room = Item.new(name => 'a room', description => 'a room')
#   player = Agent.new(name => 'player1', description => 'a player', item => room)
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

  attr_accessor :connection

  def validate
    super
    validates_presence [:name, :item]
  end

  def look(what = '')
    case what.downcase
    when '', 'here'
      connection.send_data(self.item.description + "\n")
      connection.send_data(self.item.collect_exits + "\n")
      agents = []
      agents_here.each { |ac|
        agents.push(ac.agent.name) unless ac.agent.name == name
      }
      if agents.count > 0
        connection.send_data('Players: ' + agents.join(' ') + "\n")
      end
    when 'm', 'me', 's', 'self'
      connection.send_data( (self.description || "Nothing special.") + "\n" )
    else
      connection.send_data("That isn't here to look at.\n")
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

  def agents_here
    list = []
    @connection.server.connections.each { |connection|
      if connection.agent.item == item
        list.push(connection)
      end
    }
    return list
  end

  def repl(text)
    @command = Command.new unless !@command.nil?
    @command.last = text
    @command.parse_command
    @exits = self.item.exits unless !@exits.nil?

    # check exits, triggers, etc
    case @command.last.to_s.downcase
    when *@exits.collect{|e| e.name.downcase }
      move(@command.last.to_s)
      look
      return
    end

    case @command.head.to_s.downcase
    when /^"/, 'say'
      if @command.last[0] == '"'
        @command.last[0] = ''
        msg = @command.last
      else
        msg = @command.params
      end
      connection.send_data('You say, "' + msg + "\"\n")
      agents_here.each { |ac|
        ac.send_data(name + ' says, "' + msg + "\"\n") unless ac.agent.name == name
      }
    when /^:/, 'pose'
      if @command.last[0] == ':'
        if @command.last[1] == "'"
          @command.last[0] = ''
        else
          @command.last[0] = ' '
        end
        msg = @command.last
      else
        msg = @command.params
      end
      agents_here.each { |ac|
        ac.send_data(name + msg + "\n")
      }
    when 'l', 'look'
      look(@command.params)
    when 'q', 'quit'
      connection.send_data("Quitting.\n")
      connection.close_connection_after_writing
    when 'who'
      list = []
      @connection.server.connections.each { |connection|
        list.push(connection.agent.name)
      }
      connection.send_data("Online now: " + list.join(' ') + "\n")
    # todo handle spaced exits, go and goto
    when *@exits.collect{|e| e.name.downcase }
      move(@command.head.to_s)
    else
      connection.send_data("Unknown command: '#{@command.last.to_s}'\n")
    end
  end
end

Agent.create_table unless Agent.table_exists?

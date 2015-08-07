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

  attr_accessor :connection, :exits

  def validate
    super
    validates_presence [:name, :item]
  end

  def look(what = '')
    agents = agents_here
    agent_names = []
    agents.each { |c| agent_names.push(c.agent.name.downcase) }
    case what.downcase
    when '', 'here'
      connection.send_data(self.item.description + "\n")
      connection.send_data(self.item.collect_exits + "\n")
      other_agents = []
      agents.each { |ac|
        other_agents.push(ac.agent.name) unless ac.agent.name == name
      }
      if other_agents.count > 0
        connection.send_data('Players: ' + other_agents.join(' ') + "\n")
      end
    when 'm', 'me', 's', 'self'
      connection.send_data( (self.description || "Nothing special.") + "\n" )
    when *agent_names
      desc = "Nothing special."
      agents.each { |c|
        if c.agent.name.downcase == what.downcase
          desc = c.agent.description
          c.send_data(name + " looked at you.\n")
        end
      }
      connection.send_data(desc + "\n")
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

end

Agent.create_table unless Agent.table_exists?

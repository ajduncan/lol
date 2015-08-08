# coding: UTF-8

require "rainbow/ext/string"

require "./lib/command"
require "./lib/message"
require "./lib/models/item"
require "./lib/models/item_property"
require "./lib/models/link"
require "./lib/models/link_property"


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

  def get_neighbors
    @neighbors = {}
    connections_here.each { |ac|
      @neighbors[ac.agent.name.downcase] = ac unless ac.agent.name == name
    }
  end

  def look(what = '')
    get_neighbors
    case what.downcase
    when '', 'here'
      msg = self.item.name + " [" + self.item.collect_exits + "]\n" + self.item.description + "\n"
      notify(self, msg)
      if @neighbors.count > 0
        # todo, sigh - get the collection of agent names without using them as indexes.
        if @neighbors.count == 1
          notify(self, '    ' + @neighbors.keys.join(', ').color(:cyan) + " is here.\n".color(:cyan))
        else
          notify(self, '    ' + @neighbors.keys.join(', ').color(:cyan) + " are here.\n".color(:cyan))
        end
      end
    when 'm', 'me', 's', 'self'
      notify(self, (self.description || "Nothing special.") + "\n")
    when *@neighbors.keys
      desc = @neighbors[what].agent.description
      @connection.server.connections[what.downcase].send_data(name + " looked at you\n")
      notify(self, desc + "\n")
    when name.downcase
      notify(self, description + "\n")
    else
      # whisky tango foxtrot
      notify(self, "That isn't here to look at.\n")
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

  def connections_here
    list = []
    @connection.server.connections.each { |key, connection|
      if connection.agent.item == item
        list.push(connection)
      end
    }
    return list
  end

end

Agent.create_table unless Agent.table_exists?

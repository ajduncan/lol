# coding: UTF-8

require 'sequel'

# Public: Model for working with the game world in a general sense.
#
# Examples
#
#   world = World.new
#   world.events
#
class World
  def self.events
    return "a gentle breeze blows through the area..."
  end
end

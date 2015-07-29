require 'sequel'
DB = Sequel.connect('sqlite://db/lol.db')

require './lol/models/item'
require './lol/models/item_property'
require './lol/models/link'
require './lol/models/link_property'

require 'factory_girl'
require 'rspec'
require 'sequel'
DB = Sequel.connect('sqlite://db/lol.db')

require './lol/models/item'
require './lol/models/item_property'
require './lol/models/link'
require './lol/models/link_property'
require './lol/models/agent'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.find_definitions
end

# make factorygirl work with sequel
class Sequel::Model
  alias_method :save!, :save
end

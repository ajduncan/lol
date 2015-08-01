require 'factory_girl'
require 'rspec'
require 'sequel'

Sequel::Model.plugin(:schema)
DB = Sequel.sqlite

require './lib/models/item'
require './lib/models/item_property'
require './lib/models/link'
require './lib/models/link_property'
require './lib/models/agent'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.find_definitions
end

# make factorygirl work with sequel
class Sequel::Model
  alias_method :save!, :save
end

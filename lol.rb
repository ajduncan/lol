#!/usr/bin/env ruby
# coding: UTF-8

require 'sequel'
DB = Sequel.connect('sqlite://db/lol.db')

require './lib/models/agent'
require "./lib/models/item"
require "./lib/models/item_property"
require "./lib/models/link"
require "./lib/models/link_property"
require "./lib/command"


class LOL
  def initialize
    if Item.count == 0
      puts "Run the DB setup/migration utility!"
    end

    @agent = Agent.first
  end

  def run
    @agent.look
    while true
      @agent.repl
    end
  end
end

if __FILE__ == $0
  lol = LOL.new
  lol.run
end

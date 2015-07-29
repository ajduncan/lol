#!/usr/bin/env ruby
# coding: UTF-8

require './lol/models/agent'


class LOL
  def initialize
    @agent = Agent.new
  end

  def run
    while true
      @agent.run_command
    end
  end
end

if __FILE__ == $0
  lol = LOL.new
  lol.run
end

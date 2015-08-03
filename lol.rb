#!/usr/bin/env ruby
# coding: UTF-8

require "eventmachine"
require "sequel"

Sequel::Model.plugin(:schema)
DB = Sequel.connect('sqlite://db/lol.db')
PORT = 9000
SSL_PORT = 9001

require "./lib/connection"


class LOL
  attr_accessor :connections

  def initialize
    @connections = []
  end

  def start
    puts "SSL server listening on port #{SSL_PORT}"
    @ssl_server = EventMachine.start_server("127.0.0.1", SSL_PORT, Connection) do |connection|
      connection.server = self
    end
  end

  def stop
     EventMachine.stop_server(@ssl_server)

     unless wait_for_connections_and_stop
       EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
     end
  end

  def wait_for_connections_and_stop
     if @connections.empty?
       EventMachine.stop
       true
     else
       puts "Waiting for #{@connections.size} connection(s) to stop"
       false
     end
  end

end

if __FILE__ == $0
  EM.run {
    lol = LOL.new
    lol.start
  }
end

#!/usr/bin/env ruby
# coding: UTF-8 :)

require "dotenv"; Dotenv.load
require "eventmachine"
require "em-pg-sequel"
require "em-synchrony"
require "sequel"

Sequel::Model.plugin(:schema)
DB_URL = ENV["DB_URL"] || 'sqlite://db/lol.db'
HOST = ENV["HOST"] || '0.0.0.0'
DB = Sequel.connect(DB_URL, pool_class: :em_synchrony)
PORT = ENV["PORT"] || 9000
SSL_PORT = ENV["SSL_PORT"] || 9001
MOTD_FILE = File.open("./data/motd.txt")
MOTD = MOTD_FILE.read
MOTD_FILE.close

require "./lib/connection"
require "./lib/models/world"


class LOL
  attr_accessor :connections

  def initialize
    @connections = {}
  end

  def start
    @ssl_server = EventMachine.start_server(HOST, SSL_PORT, Connection) do |connection|
      connection.server = self
    end
    puts "SSL server listening on #{HOST}:#{SSL_PORT}"

    @world_server = EM.add_periodic_timer(120) {
      events = World.events
      @connections.each { |key, connection|
        connection.send_data("#{events}\n")
      }
    }
    puts "World server started"

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
    EM.error_handler { |e|
      puts "Unhandled error: #{e.message}"
    }
  }
end

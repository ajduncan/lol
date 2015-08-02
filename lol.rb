#!/usr/bin/env ruby
# coding: UTF-8

require "socket"
require "sequel"
require "openssl"
require "thread"

Sequel::Model.plugin(:schema)
DB = Sequel.connect('sqlite://db/lol.db')
PORT = 9000

require "./lib/models/agent"
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
  end

  def run_ssl
    server = TCPServer.new(PORT)
    context = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(File.open("data/example_signed_certificate.pem"))
    context.key = OpenSSL::PKey::RSA.new(File.open("data/example_private.pem"))
    ssl_server = OpenSSL::SSL::SSLServer.new(server, context)

    puts "SSL server listening on port #{PORT}"

    loop do
      connection = ssl_server.accept
      Thread.new {
        begin
          agent = Agent.first
          agent.connection = connection
          agent.look
          while connection
            text = connection.gets.chomp
            agent.repl(text)
          end
        rescue
          $stderr.puts $!
        ensure
          connection.close
        end
      }
    end
  end
end

if __FILE__ == $0
  lol = LOL.new
  lol.run_ssl
end

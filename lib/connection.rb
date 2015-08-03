# coding: UTF-8

require "./lib/models/agent"
require "./lib/models/item"
require "./lib/models/item_property"
require "./lib/models/link"
require "./lib/models/link_property"
require "./lib/command"


class Connection < EventMachine::Connection
  attr_accessor :server
  attr_reader :agent

  def initialize
  end

  def post_init
    start_tls(:private_key_file => './data/example_private.pem', :cert_chain_file => 'data/example_signed_certificate.pem', :verify_peer => false)
  end

  def receive_data(data)
    data.strip!

    unless @agent
      handle_login(data)
    else
      handle_command(data)
    end
  end

  def unbind
    puts "Client disconnecting..."
    @server.connections.each { |connection|
      puts "Letting client know #{@agent.name} disconnected."
      connection.send_data("#{@agent.name} disconnected.\n")
    }
    @server.connections.delete(self)
  end

  private

  def handle_login(data)
    puts "handling login"
    @agent = Agent.first # replace with login etc
    @agent.connection = self
    @server.connections.each { |connection| connection.send_data("#{@agent.name} has connected.\n") }
    @server.connections << self
  end

  def handle_command(message)
    @agent.repl(message)
  end

end

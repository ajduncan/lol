# coding: UTF-8

require "bcrypt"

require "./lib/models/agent"
require "./lib/command"


class Connection < EventMachine::Connection
  attr_accessor :server
  attr_reader :agent
  attr_reader :command

  def initialize
  end

  def post_init
    start_tls(:private_key_file => './data/example_private.pem', :cert_chain_file => 'data/example_signed_certificate.pem', :verify_peer => false)
    send_data(MOTD)
    disconnect_inactive
  end

  def disconnect_inactive
    @idle_timeout = EM.add_periodic_timer(120) {
      seconds_idle = get_idle_time
      if seconds_idle > 119
        send_data("Disconnecting you for inactivity.\n")
        @idle_timeout.cancel() # is this even needed?
        close_connection_after_writing
      end
    }
  end

  def receive_data(data)
    data.strip!

    unless @agent
      handle_guest_command(data)
    else
      handle_command(data)
    end
  rescue => e
      puts "Exception handling client message: '#{data}':"
      puts e
      puts "\n################################################################################\n"
      puts e.backtrace
      puts "\n################################################################################\n"
      send_data("The server errored while handling your request: #{data}.\n")
  end

  def handle_logout
    @server.connections.delete(@agent.name.downcase)
    @agent = nil
    send_data(MOTD)
    disconnect_inactive
  end

  def unbind
    @server.connections.delete(self)
  end

  def handle_login(username, password)
    return false unless username && password
    return false unless agent = Agent.first(Sequel.function(:lower, :name) => username.to_s.downcase)
    return false unless BCrypt::Password.new(agent.password) == password
    @idle_timeout.cancel()

    # a connection has an agent, an agent has a connection
    @agent = agent
    @agent.connection = self

    # a connection has commands, command has a connection and agent
    @command = Command.new
    @command.connection = self
    @command.agent = agent

    @agent.connections_here.each { |ac|
      ac.send_data(@agent.name + " connected.\n") unless ac.agent.name == @agent.name
    }
    @server.connections[agent.name.downcase] = self
    @command.repl('l')
    return true
  end

  def handle_guest_command(data)
    tokens = data.split(' ')
    head = tokens.shift
    params = tokens.join(' ')

    case head.to_s.downcase
    when 'connect'
      if tokens.count < 2
        send_data("Usage: connect <name> <pass>\n")
      else
        username = tokens[0]
        password = tokens[1]
        if !handle_login(username, password)
          send_data("Unknown user or incorrect password.\n")
        end
      end
    when 'who'
      list = []
      @server.connections.each { |key, connection|
        list.push(connection.agent.name)
      }
      if list.count > 0
        send_data("Online now: " + list.join(' ') + "\n")
      else
        send_data("No one is on right now.\n")
      end
    when 'q', 'quit'
      send_data("Quitting.\n")
      close_connection_after_writing
    else
      send_data("Unknown command: '#{data}'\n")
    end
  end

  def handle_command(message)
    @command.repl(message)
  end

end

# coding: UTF-8


class Command

  def initialize(command = "")
    @last = command
    parse_command
  end

  attr_accessor :connection, :agent
  attr_reader :last, :tokens, :head, :params
  attr_writer :last

  def parse_command
    @tokens = @last.split(' ')
    @head = @tokens.shift
    @params = @tokens.join(' ')
  end

  def repl(text)
    @last = text
    parse_command
    agent.exits = agent.item.get_exits unless !agent.exits.nil?

    # check exits, triggers, etc
    case @last.to_s.downcase
    when *agent.exits.collect{|e| e.name.downcase }
      agent.connections_here.each { |ac|
        ac.send_data(agent.name + " leaves through the \"#{@head.to_s}\" exit.\n") unless ac.agent.name == agent.name
      }
      connection.send_data("You move through #{@head.to_s}\n")
      agent.move(@last.to_s)
      agent.connections_here.each { |ac|
        ac.send_data(agent.name + " arrives.\n") unless ac.agent.name == agent.name
      }
      agent.look
      return
    end

    case @head.to_s.downcase
    when /^"/, 'say'
      if @last[0] == '"'
        @last[0] = ''
        msg = @last
      else
        msg = @params
      end
      connection.send_data('You say, "' + msg + "\"\n")
      agent.connections_here.each { |ac|
        ac.send_data(agent.name + ' says, "' + msg + "\"\n") unless ac.agent.name == agent.name
      }
    when /^:/, 'pose'
      if @last[0] == ':'
        if @last[1] == "'"
          @last[0] = ''
        else
          @last[0] = ' '
        end
        msg = @last
      else
        msg = @params
      end
      agent.connections_here.each { |ac|
        ac.send_data(agent.name + msg + "\n")
      }
    when 'l', 'look'
      agent.look(@params)
    when 'q', 'quit'
      connection.send_data("Quitting.\n")
      agent.connections_here.each { |ac|
        ac.send_data(agent.name + " disconnected.\n") unless ac.agent.name == agent.name
      }
      connection.close_connection_after_writing
    when 'who'
      list = []
      connection.server.connections.each { |key, connection|
        list.push(connection.agent.name)
      }
      connection.send_data("Online now: " + list.join(' ') + "\n")
    else
      connection.send_data("Unknown command: '#{@last.to_s}'\n")
    end
  end
end

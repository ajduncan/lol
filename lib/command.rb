# coding: UTF-8

require "./lib/message"


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
      msg = agent.name + " leaves through the \"#{@head.to_s}\" exit.\n"
      connection_notify_except(agent.connections_here, msg, agent.name)
      connection.send_data("You move through #{@head.to_s}\n")
      agent.move(@last.to_s)
      msg = agent.name + " arrives.\n"
      connection_notify_except(agent.connections_here, msg, agent.name)
      agent.look
      return
    end

    case @head.to_s.downcase
    when 'crash'
      raise 'Deliberate client-initiated exception.'
    when /^"/, 'say'
      if @last[0] == '"'
        @last[0] = ''
        msg = @last
      else
        msg = @params
      end
      connection.send_data('You say, "' + msg + "\"\n")
      msg = agent.name + ' says, "' + msg + "\"\n"
      connection_notify_except(agent.connections_here, msg, agent.name)
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
      connection_notify(agent.connections_here, msg + "\n")
    when 'l', 'look'
      agent.look(@params)
    when 'q', 'quit'
      connection.send_data("Quitting.\n")
      connection_notify_except(agent.connections_here, agent.name + " disconnected.\n", agent.name)
      connection.close_connection_after_writing
    when 'w', 'whisper'
      whisper = @params.split('=')
      if whisper.count > 1
        who = whisper[0].split(' ')
        what = whisper[1, whisper.count].join('=').strip
        msg = whisper_correct(agent.name, what)
        agent.last_whisper = agent.connections_here(who)
        agent.last_whisper.each { |c|
          c.send_data(msg)
        }
        who_s = []
        agent.last_whisper.each { |c| who_s << c.agent.name }
        who_s = who_s.join(", ")
        connection.send_data("You whisper to " + who_s + "\n")
      else
        msg = whisper_correct(agent.name, @params)
        if agent.last_whisper != ''
          agent.last_whisper.each { |c|
            c.send_data(msg)
          }
          who_s = []
          agent.last_whisper.each { |c| who_s << c.agent.name }
          who_s = who_s.join(", ")
          connection.send_data("You whisper to " + who_s + "\n")
        else
          connection.send_data("Invalid whisper command.")
        end
      end
    when 'logout'
      connection.send_data("Logging out.\n")
      connection_notify_except(agent.connections_here, agent.name + " disconnected.\n", agent.name)
      connection.handle_logout
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

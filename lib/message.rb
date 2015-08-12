# coding: UTF-8


def whisper_correct(name, msg)
  if msg[0] == ':'
    if msg[1] == "'"
      msg[0] = ''
    else
      msg[0] = ' '
    end
    msg = name + msg + " - in a whisper to you.\n"
  else
    msg = name + ' whispers, "' + msg + '" to you.' + "\n"
  end
  return msg
end


def connection_notify_except(connection, msg, except)
  if connection.kind_of?(Array)
    connection.each{|c| c.send_data(msg) unless c.agent.name == except}
  else
    connection.send_data(msg) unless connection.agent.name == except
  end
end

def agent_notify_except(agent, msg, except)
  if agent.kind_of?(Array)
    agent.each{|a| a.connection.send_data(msg) unless a.name == except}
  else
    agent.connection.send_data(msg) unless agent.name == except
  end
end


def connection_notify(connection, msg)
  if connection.kind_of?(Array)
    connection.each{|c| c.send_data(msg)}
  else
    connection.send_data(msg)
  end
end


def agent_notify(agent, msg)
  if agent.kind_of?(Array)
    agent.each{|a| a.connection.send_data(msg)}
  else
    agent.connection.send_data(msg)
  end
end


def notify_here_except(agent, list, exceptions, msg)
end

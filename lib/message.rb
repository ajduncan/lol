# coding: UTF-8


def notify(agent, msg)
  agent.connection.send_data(msg)
end


def notify_here_except(agent, list, exceptions, msg)
end

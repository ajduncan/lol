#!/usr/bin/env ruby
# coding: UTF-8

require "rubygems"
require "eventmachine"

HOST = '127.0.0.1'
SSL_PORT = 9001


class LOLKeyboardHandler < EM::Connection
  include EM::Protocols::LineText2

  attr_reader :queue

  def initialize(q)
    @queue = q
  end

  def receive_line(data)
    @queue.push(data)
  end
end


class LOLClientSSLHandler < EM::Connection
  attr_reader :queue

  def initialize(q)
    @queue = q

    cb = Proc.new do |msg|
      send_data(msg)
      q.pop &cb
    end

    q.pop &cb
  end

  def connection_completed
    start_tls
  end

  def receive_data(data)
    puts data
  end

  def ssl_handshake_completed
    puts "SSL handshake completed successfully."
  end

  def unbinding
    puts "Disconnecting..."
  end

end

if __FILE__ == $0
  EM.run {
    q = EM::Queue.new
    EM.connect(HOST, SSL_PORT, LOLClientSSLHandler, q)
    EM.open_keyboard(LOLKeyboardHandler, q)
  }
end

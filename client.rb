#!/usr/bin/env ruby

require "openssl"
require "socket"
require "thread"

HOST = 'localhost'
PORT = 9000

class LOLClient
  def initialize
    @socket = TCPSocket.new(HOST, PORT)
    @check_cert = OpenSSL::X509::Certificate.new(File.open("data/example_signed_certificate.pem"))
    @ssl = OpenSSL::SSL::SSLSocket.new(@socket)
    @ssl.sync_close = true
  end

  def connect
    @ssl.connect
    if @ssl.peer_cert.to_s != @check_cert.to_s
      stderrr.puts "Unexpected certificate"
      exit(1)
    end
  end

  def run
    Thread.new {
      begin
        while text = @ssl.gets
          text = text.chomp
          $stdout.puts text
        end
      rescue
        $stderr.puts "Error: " + $!
      end
    }

    # afaik here detecting closed is more a recv returns "" or ECONNRESET than closed.
    @ssl.puts $stdin.gets.chomp until @socket.closed?
  end
end

if __FILE__ == $0
  lolc = LOLClient.new
  lolc.connect
  lolc.run
end

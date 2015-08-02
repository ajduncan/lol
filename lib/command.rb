# coding: UTF-8

class Command

  def initialize(command = "")
    @last = command
    parse_command
  end

  attr_reader :last, :tokens, :head, :params
  attr_writer :last

  def parse_command
    @tokens = @last.split(' ')
    @head = @tokens.shift
    @params = @tokens.join(' ')
  end

  def get_command
    put "$ "
    @last = $stdin.gets.chomp
    parse_command
  end

end

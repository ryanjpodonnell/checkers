require_relative 'player'
require_relative 'board'
require_relative 'piece'
require 'colorize'
require 'debugger'

class MyError < StandardError
end


class Checkers
  attr_reader :board, :current_player, :players
  
  def initialize
    @board = Board.new(true)
    @players = {
      :red => HumanPlayer.new(:red),
      :blue => HumanPlayer.new(:blue)
    }
    @current_player = :red
  end
  
  def play
    until board.count_pieces(:red) == 0 || board.count_pieces(:blue) == 0
      players[current_player].play_turn(board)
      @current_player = (current_player == :red) ? :blue : :red
    end
  end
end



if $PROGRAM_NAME == __FILE__    
  checkers = Checkers.new
  checkers.play
end
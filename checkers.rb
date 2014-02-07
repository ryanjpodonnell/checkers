require 'colorize'

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


class HumanPlayer
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn(board)
    begin
      moves_arr = []
      
      puts board.render
      puts "Current player: #{color}"

      moves_arr << get_pos("From pos:")
      moves_arr << get_pos("To pos:")
      puts "How many to chain?:"
      num_chains = gets.chomp.to_i
      num_chains.times do |i|
        moves_arr << get_pos("To pos:")
      end
      
      dupped = board.dup_board
      dupped[moves_arr[0]].perform_moves!(moves_arr, color)
            
      board[moves_arr[0]].perform_moves!(moves_arr, color)
      # if board[from_pos].color != @color
      #   raise StandardError.new("chose opponents piece") 
      # end       
      # if (from_pos[0] - to_pos[0]).abs == 1
      #   if board[from_pos].perform_slide(to_pos) == false
      #     raise StandardError.new("invalid slide")
      #   end
      # else
      #   if board[from_pos].perform_jump(to_pos) == false
      #     raise StandardError.new("invalid jump") 
      #   end
      # end

    rescue MyError => e
      puts "ERROR: #{e.message}"
      
      retry
    end
  end

  private
  def get_pos(prompt)
    puts prompt
    gets.chomp.split(",").map { |coord_s| coord_s.to_i }
  end
end


class Board
  attr_accessor :rows
  
  def initialize(init)
    @rows = Array.new(10) {Array.new(10)}
    initialize_board if init == true
  end
  
  def [](pos)
    row, col = pos
    @rows[row][col]
  end
  
  def []=(pos, piece)
    row, col = pos
    @rows[row][col] = piece
  end
  
  def count_pieces(color)
    count = 0
    @rows.each do |row|
      row.each do |square|
        if !square.nil? && square.color == color
          count += 1
        end
      end
    end
    count
  end
  
  def initialize_board
    @rows.count.times do |row_idx|
      @rows.count.times do |col_idx|
        if row_idx < 4 && (row_idx+col_idx).odd?
          @rows[row_idx][col_idx] = Piece.new(self, :blue, [row_idx, col_idx], false)
        elsif row_idx > 5  && (row_idx+col_idx).odd?
          @rows[row_idx][col_idx] = Piece.new(self, :red, [row_idx, col_idx], false)
        end
      end
    end
  end
  
  def dup_board
    duped = Board.new(false)
    duped.rows.each_with_index do |row, row_idx|
      row.each_with_index do |square, col_idx|
        if !self.rows[row_idx][col_idx].nil?
          duped.rows[row_idx][col_idx] = 
          Piece.new(duped, 
                    self.rows[row_idx][col_idx].color, 
                    [row_idx, col_idx], 
                    self.rows[row_idx][col_idx].king)
        end
      end
    end
    duped
  end
  
  def render
    row_counter = 0
    render_string = "  0 1 2 3 4 5 6 7 8 9\n"
    @rows.each_with_index do |row, row_idx|
      render_string << row_counter.to_s.ljust(2)
      row.each_with_index do |square, col_idx|
        if square.nil?
          if (row_idx + col_idx).odd?
            render_string << "  ".colorize(:background => :black)
          else
            render_string << "  ".colorize(:background => :white)
          end
        else
          render_string << square.render
        end
      end
      render_string << "\n"
      row_counter += 1
    end
    render_string << "\n"
    render_string
  end
end


class Piece
  attr_accessor :board, :color, :pos, :king
  
  BLUE = [
    [1,  1],
    [1, -1]
  ]
  
  RED = [
    [-1, -1],
    [-1,  1]
  ]
  
  def initialize(board, color, pos, king)
    @board = board
    @color = color
    @pos   = pos
    @king  = king
  end
  
  def perform_slide(pos)
    if @board[pos].nil? && possible_steps(1).include?(pos)
      @board[self.pos] = nil
      @board[pos]      = self
      self.pos         = pos
      return true
    end
    false
  end
  
  def perform_jump(pos)
    if @board[pos].nil? && 
      possible_steps(2).include?(pos) && piece_between(pos).color != @color
      
      @board[piece_between(pos).pos] = nil 
      @board[self.pos] = nil
      @board[pos]      = self
      self.pos         = pos
      return true
    end
    false
  end
  
  def perform_moves!(moves_arr, moving_color)
    if board[moves_arr[0]].color != moving_color
      raise MyError.new("chose opponents piece") 
    end
    
    if moves_arr.count == 2
      from_pos = moves_arr[0]
      to_pos   = moves_arr[1]
      
      if (from_pos[0] - to_pos[0]).abs == 1
        if board[from_pos].perform_slide(to_pos) == false
          raise MyError.new("invalid slide")
        end
      else
        if board[from_pos].perform_jump(to_pos) == false
          raise MyError.new("invalid jump") 
        end
      end
      
      board[to_pos].maybe_promote
      return
    end
    
    from_pos = moves_arr.shift
    until moves_arr.empty?
      to_pos   = moves_arr.shift
      
      p from_pos
      p to_pos
      
      if board[from_pos].perform_jump(to_pos) == false
        raise MyError.new("invalid jump") 
      end
      board[to_pos].maybe_promote
      
      from_pos = to_pos
    end
  end
  
  def maybe_promote
    if (color == :blue && pos[0] == 9) || (color == :red && pos[0] == 0)
      king = true
    end
  end
  
  def piece_between(pos)
    mid_pos = [(@pos[0] + pos[0]) / 2, (@pos[1] + pos[1]) / 2]
    return false if @board[mid_pos].nil?
    @board[mid_pos]
  end
  
  def possible_steps(num_steps)
    possible_moves = []
    self.move_diffs.each do |move|
      pot_move = [move[0] * num_steps, move[1] * num_steps]
      pot_row, pot_col = pot_move[0] + @pos[0], pot_move[1] + @pos[1]
      if pot_row.between?(0, 9) && pot_col.between?(0, 9)
        possible_moves << [pot_row, pot_col]
      end
    end
    possible_moves
  end
  
  def move_diffs
    @king == true ? BLUE + RED : @color == :red ? RED : BLUE
  end
  
  def render
    if @color == :red && @king == false
      return "\u25CF ".colorize(:color => :red, :background => :black)
    elsif @color == :red && @king == true
      return "\u25C9 ".colorize(:color => :red, :background => :black)
    elsif @color == :blue && @king == false
      return "\u25CF ".colorize(:color => :blue, :background => :black)
    else
      return "\u25C9 ".colorize(:color => :blue, :background => :black)
    end
  end
end

if $PROGRAM_NAME == __FILE__    
  checkers = Checkers.new
  checkers.play
end
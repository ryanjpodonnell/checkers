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
  
  def handle_two_moves(moves_arr)
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
  end
  
  def handle_more_than_two_moves(moves_arr)
    from_pos = moves_arr.shift
    until moves_arr.empty?
      to_pos   = moves_arr.shift
      
      if board[from_pos].perform_jump(to_pos) == false
        raise MyError.new("invalid jump") 
      end
      board[to_pos].maybe_promote
      
      from_pos = to_pos
    end
  end
  
  def perform_moves!(moves_arr, moving_color)
    if board[moves_arr[0]].color != moving_color
      raise MyError.new("chose opponents piece") 
    end
    
    if moves_arr.count == 2
      handle_two_moves(moves_arr)
      return
    end
    
    handle_more_than_two_moves(moves_arr)
  end
  
  def maybe_promote
    if (color == :blue && pos[0] == 9) || (color == :red && pos[0] == 0)
      self.king = true
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
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
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
      dupped_arr = moves_arr.dup
      dupped[moves_arr[0]].perform_moves!(dupped_arr, color)
      board[moves_arr[0]].perform_moves!(moves_arr, color)
      
    rescue MyError => e
      puts "ERROR: #{e.message}"
      
      retry
    rescue StandardError => e
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
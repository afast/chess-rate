module Board
  class Rook < Piece
    def can_move_to? position
      can_move = if @position.rank_movement? position
        @board.empty_files_between?(@position, position)
      elsif @position.file_movement? position
        @board.empty_ranks_between?(@position, position)
      else
        false
      end
      puts "Rook at #{@position} can move to #{position}? - #{can_move}"
      can_move
    end

    def board_print
      side == :black ? 'r' : 'R'
    end
  end
end

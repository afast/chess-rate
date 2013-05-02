module Board
  class Bishop < Piece
    def can_move_to? position
      can_move = if @position.diagonal_movement? position
        @board.empty_diagonal_between? @position, position
      else
        false
      end
      puts "Bishop at #{@position} can move to #{position}? - #{can_move}"
      can_move
    end

    def board_print
      side == :black ? 'b' : 'B'
    end
  end
end

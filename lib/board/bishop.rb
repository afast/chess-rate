module Board
  class Bishop < Piece
    def can_move_to? position
      can_move = if @position.diagonal_movement? position
        @board.empty_diagonal_between? @position, position
      else
        false
      end
      can_move
    end

    def board_print
      side == :black ? 'b' : 'B'
    end
  end
end

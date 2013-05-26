module Board
  class Queen < Piece
    def can_move_to? position
      can_move = if @position.rank_movement? position
        @board.empty_files_between? @position, position
      elsif @position.file_movement? position
        @board.empty_ranks_between? @position, position
      elsif @position.diagonal_movement? position
        @board.empty_diagonal_between? @position, position
      else
        false
      end

      can_move
    end

    def board_print
      side == :black ? 'q' : 'Q'
    end
  end
end

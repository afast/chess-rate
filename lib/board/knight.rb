module Board
  class Knight < Piece
    def can_move_to? position
      @position.rank_distance(position) == 2 && @position.file_distance(position) == 1 ||
        @position.rank_distance(position) == 1 && @position.file_distance(position) == 2
    end

    def board_print
      side == :black ? 'n' : 'N'
    end
  end
end

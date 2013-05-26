module Board
  class Knight < Piece
    def can_move_to? position
      can_move = @position.rank_distance(position) == 2 && @position.file_distance(position) == 1 ||
        @position.rank_distance(position) == 1 && @position.file_distance(position) == 2
      puts "#{board_print} to #{position}? - #{can_move}"
      can_move
    end

    def board_print
      side == :black ? 'n' : 'N'
    end
  end
end

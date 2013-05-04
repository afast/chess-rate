module Board
  class Pawn < Piece
    def can_move_to? position
      return InvalidPositionError.new unless position.valid?
      rank_dis = @position.rank_distance(position) # rank distance
      file_dis = @position.file_distance(position) # file distance

      can_move = rank_dis == 1 && (file_dis == 0 && @board.square_empty?(position) || file_dis == 1 && !@board.square_empty?(position) ) # can move forward
      can_move = can_move || rank_dis == 2 && file_dis == 0 && # en passant
        @board.empty_ranks_between?(@position, position)

      can_move
    end

    def board_print
      side == :black ? 'p' : 'P'
    end
  end
  class InvalidPositionError < StandardError; end
end

module Board
  class King < Piece
    def can_move_to? position
      [0,1].include?(@position.file_distance(position)) &&
        [0,1].include?(@position.file_distance(position))
    end

    def move_to position
      raise NoPositionError.new unless @position && position
      if @position.file_distance(position) > 1
        castling = true
      end
      from = @position.to_s
      @board.set_piece(nil, file_to_i, rank) # empty from coords
      @board.eliminate @board.piece_at(position) # eliminate piece if there was one

      @position = position
      @board.set_piece(self, file_to_i, rank) # place piece in new coords

      if castling
        if position.file == 'g' # short castling
          rook = @board.piece_at_file_rank(Position.file_to_i('h'), position.rank)
          rook.position = Position.new('f', position.rank)
          @board.set_piece nil, Position.file_to_i('h'), position.rank
          @board.set_piece rook, Position.file_to_i('f'), position.rank
        elsif position.file == 'c' # long castling
          rook = @board.piece_at_file_rank(Position.file_to_i('a'), position.rank)
          rook.position = Position.new('d', position.rank)
          @board.set_piece nil, Position.file_to_i('a'), position.rank
          @board.set_piece rook, Position.file_to_i('d'), position.rank
        end
      end

      from # return algebraic old source
    end

    def board_print
      side == :black ? 'k' : 'K'
    end
  end
end

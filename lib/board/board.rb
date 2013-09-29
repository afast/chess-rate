require 'position'
require 'piece'
require 'bishop'
require 'king'
require 'knight'
require 'pawn'
require 'queen'
require 'rook'

module Board
  class Board
    attr_accessor :en_passant

    def initialize
      @board = Array.new(8)
      (0..7).each do |i|
        @board[i] = Array.new(8)
      end
    end

    def setup_board
      8.times.each do |i|
        8.times.each do |j|
          @board[i][j] = nil
        end
      end
      @pawns = {white: [], black: []}
      @rooks = {white: [], black: []}
      @knights = {white: [], black: []}
      @bishops = {white: [], black: []}
      @queens = {white: [], black: []}
      @kings = {white: nil, black: nil}

      # white
      # rooks
      @rooks[:white] << @board[0][0] = Rook.new(self, :white, Position.new('a', 1))
      @rooks[:white] << @board[7][0] = Rook.new(self, :white, Position.new('h', 1))
      # knights
      @knights[:white] << @board[1][0] = Knight.new(self, :white, Position.new('b', 1))
      @knights[:white] << @board[6][0] = Knight.new(self, :white, Position.new('g', 1))
      # bishop
      @bishops[:white] << @board[2][0] = Bishop.new(self, :white, Position.new('c', 1))
      @bishops[:white] << @board[5][0] = Bishop.new(self, :white, Position.new('f', 1))
      # queen
      @queens[:white] << @board[3][0] = Queen.new(self, :white, Position.new('d', 1))
      # king
      @kings[:white] = @board[4][0] = King.new(self, :white, Position.new('e', 1))

      Position::FILES.each_with_index do |file,index|
        @pawns[:white] << @board[index][1] = Pawn.new(self, :white, Position.new(file, 2))
      end

      # blank
      # rooks
      @rooks[:black] << @board[0][7] = Rook.new(self, :black, Position.new('a', 8))
      @rooks[:black] << @board[7][7] = Rook.new(self, :black, Position.new('h', 8))
      # knights
      @knights[:black] << @board[1][7] = Knight.new(self, :black, Position.new('b', 8))
      @knights[:black] << @board[6][7] = Knight.new(self, :black, Position.new('g', 8))
      # bishop
      @bishops[:black] << @board[2][7] = Bishop.new(self, :black, Position.new('c', 8))
      @bishops[:black] << @board[5][7] = Bishop.new(self, :black, Position.new('f', 8))
      # queen
      @queens[:black] << @board[3][7] = Queen.new(self, :black, Position.new('d', 8))
      # king
      @kings[:black] = @board[4][7] = King.new(self, :black, Position.new('e', 8))

      Position::FILES.each_with_index do |file,index|
        @pawns[:black] << @board[index][6] = Pawn.new(self, :black, Position.new(file, 7))
      end
    end

    def move(m, side) # move string and side (white, black)
      move_hash = expand_move m, side
      position_to = Position.from_algebraic_notation(move_hash[:to])
      piece = get_piece move_hash[:name], side,
                        position_to, Position.from_algebraic_notation(move_hash[:dis])
      if piece
        move_hash[:from] = piece.move_to position_to # returns long algebraic notation
        unless move_hash[:promotion].blank?
          promote(move_hash, position_to, side)
        end
        move_hash[:from] + move_hash[:to]
      else
        raise "Could not move piece #{move_hash[:name]} (dis: #{move_hash[:dis]}) to #{move_hash[:to]}"
      end
    end

    def promote(move_hash, position_to, side)
      eliminate(piece_at(position_to))
      case move_hash[:promotion].downcase
      when 'q'
        piece = Queen.new(self, side, position_to)
        @queens[side] << piece
      when 'r'
        piece = Rook.new(self, side, position_to)
        @rooks[side] << piece
      when 'b'
        piece = Bishop.new(self, side, position_to)
        @bishops[side] << piece
      when 'n'
        piece = Knight.new(self, side, position_to)
        @knights[side] << piece
      end

      set_piece(piece, position_to.file_to_i, position_to.rank)
    end

    def eliminate(piece)
      return unless piece
      case piece
      when Rook
        @rooks[piece.side].delete piece
      when Knight
        @knights[piece.side].delete piece
      when Bishop
        @bishops[piece.side].delete piece
      when Queen
        @queens[piece.side].delete piece
      when King
        @kings[piece.side] = nil
      when Pawn
        @pawns[piece.side].delete piece
      end
    end

    def piece_at(position)
      piece_at_file_rank(position.file_to_i, position.rank)
    end

    def set_piece(piece, file, rank)
      @board[file-1][rank-1] = piece
    end

    def piece_at_file_rank(file, rank)
      @board[file-1][rank-1]
    end

    def square_empty?(position)
      @board[position.file_to_i-1][position.rank-1].nil?
    end

    def empty_ranks_between?(rank_from, rank_to)
      ranks = [rank_from.rank, rank_to.rank]
      rank_check = ((ranks.min+1)..(ranks.max-1)).map { |r| @board[rank_from.file_to_i-1][r-1].nil? }.inject(:&)
      rank_check || rank_check.nil?
    end

    def empty_files_between?(file_from, file_to)
      files = [file_from.file_to_i, file_to.file_to_i]
      file_check = ((files.min+1)..(files.max-1)).map { |f| @board[f-1][file_from.rank-1].nil? }.inject(:&)
      file_check || file_check.nil?
    end

    def empty_diagonal_between?(position_from, position_to)
      rank_increment = position_from.rank_increment? position_to # get rank increment
      file_increment = position_from.file_increment? position_to # get file increment
      diag_checks = (position_from.rank - position_to.rank).abs - 1
      rank_i = position_from.rank + rank_increment - 1
      file_i = position_from.file_to_i + file_increment - 1
      diag_checks.times.each do
        return false unless @board[file_i][rank_i].nil?
        file_i += file_increment
        rank_i += rank_increment
      end
      true
    end

    def print_board
      puts '  ABCDEFGH'
      (0..7).each do |i|
        puts (7-i+1).to_s + ' ' + (0..7).map { |j| @board[j][7-i].nil? ? '.' : @board[j][7-i].board_print }.join + ' ' + (7-i+1).to_s
      end
      puts '  ABCDEFGH'
    end

    private
    def get_piece name, side, destination, dis
      name.downcase!
      if dis && dis.valid?
        return @board[dis.file_to_i-1][dis.rank-1]
      end

      pieces = case name
      when 'p'
        @pawns[side].select { |p| p.can_move_to?(destination) }
      when 'r'
        @rooks[side].select { |r| r.can_move_to?(destination) }
      when 'n'
        @knights[side].select { |n| n.can_move_to?(destination) }
      when 'b'
        @bishops[side].select { |b| b.can_move_to?(destination) }
      when 'q'
        @queens[side].select { |q| q.can_move_to?(destination) }
      when 'k'
        @kings[side]
      end

      if dis
        if dis.valid_rank?
          piece = pieces.select{ |p| p.on_rank?(dis.rank)}.first
        elsif dis.valid_file?
          piece = pieces.select{ |p| p.on_file?(dis.file)}.first
        else
          piece = if pieces.is_a? Array
            piece = pieces.first
          else
            pieces
          end
        end
      end
      print_board unless piece
      piece
    end

    # Expand the short algebraic chess notation string +m+ in a hash like this:
    #     Ngxe2 ==> { :name => 'N', :dis => 'g', :from => nil, :to => 'e2', :promotion => '' }
    def expand_move(m, side)
      if match = m.match(/^(R|N|B|Q|K)?([a-h]?[1-8]?)(?:x)?([a-h][1-8])(?:=?(R|N|B|Q))?(?:ep)?(?:\+|\#)?$/)
        expand = {
          :name => match[1] || 'P',    # Piece name (P|R|N|B|Q|K)
          :dis => match[2],            # Disambiguating move
          :to => match[3],             # Move to
          :promotion => match[4].to_s, # Promote with
        }
        expand[:from] = match[2] if match[2] && match[2].size == 2
        return expand
      elsif m =~ /^(0|O)-(0|O)(\+|\#)?$/
        if side == :black # black king short castling
          return { :name => 'K', :dis => '', :from => 'e8', :to => 'g8', :promotion => '' }
        else # white king short castling
          return { :name => 'K', :dis => '', :from => 'e1', :to => 'g1', :promotion => '' }
        end
      elsif m =~ /^(0|O)-(0|O)-(0|O)(\+|\#)?$/
        if side == :black # black king long castling
          return { :name => 'K', :dis => '', :from => 'e8', :to => 'c8', :promotion => '' }
        else # white king long castling
          return { :name => 'K', :dis => '', :from => 'e1', :to => 'c1', :promotion => '' }
        end
      end
    end
  end
end

# The UCI gem allows for a much more ruby-like way of communicating with chess
# engines that support the UCI protocol.

require 'open3'
require 'io/wait'

class Uci
  attr_reader :moves, :debug
  attr_accessor :movetime
  VERSION = "0.0.2"

  RANKS = {
    'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3,
    'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7
  }
  PIECES = {
    'p' => :pawn,
    'r' => :rook,
    'n' => :knight,
    'b' => :bishop,
    'k' => :king,
    'q' => :queen
  }

  # make a new connection to a UCI engine
  #
  # ==== Options
  #
  # Required options:
  # * :engine_path - path to the engine executable
  #
  # Optional options:
  # * :debug - enable debugging messages - true /false
  # * :name - name of the engine - string
  # * :movetime - max amount of time the engine can "think" in ms - default 100
  # * :options - hash to pass to the engine for configuration
  def initialize(options = {})
    options = default_options.merge(options)
    require_keys!(options, [:engine_path, :movetime])
    @movetime = options[:movetime]

    set_debug(options)
    reset_board!
    set_startpos!

    check_engine(options) unless options[:engine_path] =~ /^wine/
    set_engine_name(options)
    open_engine_connection(options[:engine_path])
    write_to_engine('uci')
    set_engine_options(options[:options]) if !options[:options].nil?
    #new_game!
  end

  def close_engine_connection
    @engine_stdin.close
    @engine_stdout.close
    puts 'Killing engine' if @debug
    Process.kill 'KILL', @wait_thr.pid
  end

  # true if engine is ready, false if not yet ready
  def ready?
    write_to_engine('isready')
    read_from_engine == "readyok"
  end

  def wait_for_readyok
    write_to_engine('isready')
    loop do
      break if read_from_engine == "readyok"
    end
  end

  # send "ucinewgame" to engine, reset interal board to standard starting
  # layout
  def new_game!
    write_to_engine('ucinewgame')
    reset_board!
    set_startpos!
    @fen = nil
    wait_for_readyok
  end

  # true if no moves have been recorded yet
  def new_game?
    moves.empty?
  end

  def go_infinite
    write_to_engine("go infinite")
  end

  def analyse_position
    scores = {}
    machine_move= nil
    write_to_engine "go movetime #{@movetime}"

    until (move_string = read_engine_no_filter).match(/[a-z]/) && move_string =~ /^bestmove/
      #puts move_string if move_string.match(/[a-z]/)
      puts move_string if move_string.match(/ERROR/) && @debug
      score = move_string.scan(/score cp (-?[0-9]+)/).last
      if score && move_string.scan(/ pv ([a-h][1-8][a-h][1-8]) /).last && move_string.match(/upperbound|lowerbound|mate/).nil?
        if (move = move_string.scan(/ pv ([a-h][1-8][a-h][1-8]) /).last.last)
          scores[move] = score.last.to_i/100.0
        end
      elsif (mate = move_string.scan(/score mate (-?)[0-9]+/).last)
        if mate.last && mate.last == '-'
          scores[move] = -327.4
        else
          scores[move] = 327.4
        end
      end
    end
    begin
      machine_move = read_bestmove move_string
    rescue NoMoveError
      puts 'NullMove mate in ?'
      puts $!
      machine_move = nil # Player Resigned
    end
    if scores.size == 1 && scores.keys.first.nil?
      scores = {machine_move => scores[nil]}
    end
    return scores[machine_move], machine_move
  end

  def read_engine_no_filter
    #if @engine_stdout.ready?
      response = @engine_stdout.readline
      puts "Engine: #{response}" if @debug
    #else
      #response = ''
    #end
    if response.split('').last == "\n"
      response.chop
    else
      response
    end
  end

  def analyze_move(previous_score, white, move=nil)
    command = "go movetime #{@movetime}"
    if move.nil?
      #puts "~ analyse command for #{white ? 'white' : 'black'} >> #{command}"
      write_to_engine command
    else
      command += " searchmoves #{move}"
      #puts "~ analyse command for #{white ? 'white' : 'black'} >> #{command}"
      write_to_engine command
    end
    scores = {}
    until (move_string = read_engine_no_filter).match(/[a-z]/) && move_string =~ /^bestmove/
      #puts move_string if move_string.match(/[a-z]/)
      puts move_string if move_string.match(/ERROR/)
      score = move_string.scan(/score cp (-?[0-9]+)/).last
      if score && move_string.scan(/ pv ([a-h][1-8][a-h][1-8][+#qnrb]?) /).last && move_string.match(/upperbound|lowerbound|mate/).nil?
        if (move = move_string.scan(/ pv ([a-h][1-8][a-h][1-8]) /).last.last)
          scores[move] = score.last.to_i/100.0
        end
      elsif (mate = move_string.scan(/score mate (-?)[0-9]+/).last)
        if mate.last && mate.last == '-'
          scores[move] = -327.4
        else
          scores[move] = 327.4
        end
      end
    end
    begin
      bestmove = read_bestmove move_string
    rescue NoMoveError
      puts 'NullMove mate in ?'
      puts $!
      bestmove = nil # Player Resigned
    end
    if scores.size == 1 && scores.keys.first.nil?
      scores = {bestmove => scores[nil]}
    end
    return scores, bestmove
  end

  def read_bestmove(move_string)
    if move_string =~ /^bestmove/
      if move_string =~ /^bestmove\sa1a1/ # fruit and rybka
        raise EngineResignError, "Engine Resigns. Check Mate? #{move_string}"
      elsif move_string =~ /^bestmove\sNULL/ # robbolita
        raise NoMoveError, "No more moves: #{move_string}"
      elsif move_string =~ /^bestmove\s\(none\)\s/ #stockfish
        raise NoMoveError, "No more moves: #{move_string}"
      elsif bestmove = move_string.match(/^bestmove\s([a-h][1-8][a-h][1-8])([a-z]{1}?)/)
        return bestmove[1..-1].join
      else
        raise UnknownBestmoveSyntax, "Engine returned a 'bestmove' that I don't understand: #{move_string}"
      end
    else
      raise ReturnStringError, "Expected return to begin with 'bestmove', but got '#{move_string}'"
    end
  end

  # ask the chess engine what the "best move" is given the current state of
  # the internal chess board. This does *not* actiually execute a move, it
  # simply queries for and returns what the engine would consider to be the
  # best option available.
  def bestmove
    write_to_engine("go movetime #{@movetime}")
    until (move_string = read_from_engine).to_s.size > 1 && move_string =~ /^bestmove/
      sleep 0.25
    end
    read_bestmove move_string
  end

  # write board position information to the UCI engine, either the starting
  # position + move log or the current FEN string, depending on how the board
  # was set up.
  def send_position_to_engine
    if @fen
      write_to_engine("position fen #{@fen}")
    else
      position_str = "position startpos"
      position_str << " moves #{@moves.join(' ')}" unless @moves.empty?
      #puts "send position to engine >#{position_str}<"
      write_to_engine(position_str)
    end
  end

  # tell the engine what the current board layout it, get its best move AND
  # execute that move on the current board.
  def go!
    send_position_to_engine
    move_piece(bestmove)
  end

  # move a piece on the current interal board.
  #
  # ==== Attributes
  # * move_string = algebraic standard notation of the chess move. Shorthand not allowed.
  #
  # Simple movement:              a2a3
  # Castling (king's rook white): e1g1
  # Pawn promomition (to Queen):  a7a8q
  #
  # Note that there is minimal rule checking here, illegal moves will be executed.
  def move_piece(move_string)
    raise BoardLockedError, "Board was set from FEN string" if @fen
    (move, extended) = *move_string.match(/^([a-h][1-8][a-h][1-8])([a-z]{1}?)$/)[1..2]

    start_pos = move.downcase.split('')[0..1].join
    end_pos = move.downcase.split('')[2..3].join
    (piece, player) = get_piece(start_pos)

    place_piece(player, piece, end_pos)
    clear_position(start_pos)

    if extended.to_s.size > 0
      if %w[q r b n].include?(extended)
        place = move.split('')[2..3].join
        p, player = get_piece(place)
        log("pawn promotion: #{p} #{player}")
        place_piece(player, piece_name(extended), place)
      else
        raise UnknownNotationExtensionError, "Unknown notation extension: #{move_string}"
      end
    end

    # detect castling
    if piece == :king
      start_rank = start_pos.split('')[1]
      start_file = start_pos.split('')[0].ord
      end_file = end_pos.split('')[0].ord
      if(start_file - end_file).abs > 1
        # assume the engine knows the rook is present
        if start_file < end_file # king's rook
          place_piece(player, :rook, "f#{start_rank}")
          clear_position("h#{start_rank}")
        elsif end_file < start_file # queen's rook
          place_piece(player, :rook, "d#{start_rank}")
          clear_position("a#{start_rank}")
        else
          raise "Unknown castling behviour!"
        end
      end
    end

    @moves << move_string
  end

  # return the current movement log
  def moves
    @moves
  end

  # get the details of a piece at the current position
  # raises NoPieceAtPositionError if position is unoccupied
  #
  # returns array of [:piece, :player]
  #
  # ==== Example
  #
  # > get_piece("a2")
  # => [:pawn, :white]
  def get_piece(position)
    rank = RANKS[position.to_s.downcase.split('').first]
    file = position.downcase.split('').last.to_i-1
    piece = @board[file][rank]
    if piece.nil?
      raise NoPieceAtPositionError, "No piece at #{position}!"
    end
    player = if piece =~ /^[A-Z]$/
      :white
    else
      :black
    end
    [piece_name(piece), player]
  end

  # returns a boolean if a position is occupied
  #
  # ==== Example
  #
  # > piece_at?("a2")
  # => true
  # > piece_at?("a3")
  # => false
  def piece_at?(position)
    rank = RANKS[position.to_s.downcase.split('').first]
    file = position.downcase.split('').last.to_i-1
    !!@board[file][rank]
  end

  # Returns the piece name OR the piece icon, depending on that was passes.
  #
  # ==== Example
  #
  # > piece_name(:n)
  # => :knight
  # > piece_name(:queen)
  # => "q"
  def piece_name(p)
    if p.class.to_s == "Symbol"
      (p == :knight ? :night : p).to_s.downcase.split('').first
    else
      PIECES[p.downcase]
    end
  end

  # clear a position on the board, regardless of occupied state
  def clear_position(position)
    raise BoardLockedError, "Board was set from FEN string" if @fen
    rank = RANKS[position.to_s.downcase.split('').first]
    file = position.downcase.split('').last.to_i-1
    @board[file][rank] = nil
  end

  # place a piece on the board, regardless of occupied state
  #
  # ==== Attributes
  # * player - symbol: :black or :white
  # * piece - symbol: :pawn, :rook, etc
  # * position - a2, etc
  def place_piece(player, piece, position)
    raise BoardLockedError, "Board was set from FEN string" if @fen
    rank_index = RANKS[position.downcase.split('').first]

    file_index = position.split('').last.to_i-1
    icon = (piece == :knight ? :night : piece).to_s.split('').first
    (player == :black ? icon.downcase! : icon.upcase!)
    @board[file_index][rank_index] = icon
  end

  # set the board using Forsyth–Edwards Notation (FEN), *LONG* format including
  # move, castling, etc.
  #
  # ==== Attributes
  # * fen - rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1 (Please
  # see http://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)
  def set_board(fen)
    # rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1
    fen_pattern = /^[a-zA-Z0-9\/]+\s[bw]\s[kqKQ-]+\s[a-h0-8-]+\s\d+\s\d+$/
    unless fen =~ fen_pattern
      raise FenFormatError, "Fenstring not correct: #{fen}. Expected to match #{fen_pattern}"
    end
    reset_board!
    fen.split(' ').first.split('/').reverse.each_with_index do |rank, rank_index|
      file_index = 0
      rank.split('').each do |file|
        if file.to_i > 0
          file_index += file.to_i
        else
          @board[rank_index][file_index] = file
          file_index += 1
        end
      end
    end
    new_game!
    @fen = fen
    send_position_to_engine
  end

  # return the state of the interal board in a FEN (Forsyth–Edwards Notation)
  # string, *SHORT* format (no castling info, move, etc)
  def fenstring
    fen = []
    (@board.size-1).downto(0).each do |rank_index|
      rank = @board[rank_index]
      if rank.include?(nil)
        if rank.select{|r|r.nil?}.size == 8
          fen << 8
        else
          rank_str = ""
          empties = 0
          rank.each do |r|
            if r.nil?
              empties += 1
            else
              if empties > 0
                rank_str << empties.to_s
                empties = 0
              end
              rank_str << r
            end
          end
          rank_str << empties.to_s if empties > 0
          fen << rank_str
        end
      else
        fen << rank.join('')
      end
    end
    fen.join('/')
  end

  # ASCII-art representation of the current internal board.
  #
  # ==== Example
  #
  # > puts board
  #   ABCDEFGH
  # 8 r.bqkbnr
  # 7 pppppppp
  # 6 n.......
  # 5 ........
  # 4 .P......
  # 3 ........
  # 2 P.PPPPPP
  # 1 RNBQKBNR
  #
  def board(empty_square_char = '.')
    board_str = "  ABCDEFGH\n"
    (@board.size-1).downto(0).each do |rank_index|
      line = "#{rank_index+1} "
      @board[rank_index].each do |cell|
        line << (cell.nil? ? empty_square_char : cell)
      end
      board_str << line+"\n"
    end
    board_str
  end


  # return the current engine name
  def engine_name
    @engine_name
  end

protected

  def set_engine_options(options)
    options.each do |k,v|
      write_to_engine("setoption name #{k} value #{v}")
    end
  end

  def write_to_engine(message, send_cr=true)
    log("\twrite_to_engine")
    log("\t\tME:    \t'#{message}'")
    puts "ChessRate: #{message}" if @debug
    if send_cr && message.split('').last != "\n"
      @engine_stdin.puts message
    else
      @engine_stdin.print message
    end
  end

  def read_from_engine(strip_cr=true)
    log("\tread_from_engine") #XXX
    response = ""
    #while @engine_stdout.ready?
      unless (response = @engine_stdout.readline) =~ /^info/
        log("\t\tENGINE:\t'#{response}'")
        puts "Engine: #{response}" if @debug
      else
        puts "Engine: #{response}" if response.size > 0 && @debug
      end
    #end
    if strip_cr && response.split('').last == "\n"
      response.chop
    else
      response
    end
  end

private

  def reset_move_record!
    @moves = []
  end

  def reset_board!
    @board = []
    8.times do |x|
      @board[x] ||= []
      8.times do |y|
        @board[x] << nil
      end
    end
    reset_move_record!
  end

  def set_startpos!
    %w[a b c d e f g h].each do |f|
      place_piece(:white, :pawn, "#{f}2")
      place_piece(:black, :pawn, "#{f}7")
    end

    place_piece(:white, :rook, "a1")
    place_piece(:white, :rook, "h1")
    place_piece(:white, :night, "b1")
    place_piece(:white, :night, "g1")
    place_piece(:white, :bishop, "c1")
    place_piece(:white, :bishop, "f1")
    place_piece(:white, :king, "e1")
    place_piece(:white, :queen, "d1")

    place_piece(:black, :rook, "a8")
    place_piece(:black, :rook, "h8")
    place_piece(:black, :night, "b8")
    place_piece(:black, :night, "g8")
    place_piece(:black, :bishop, "c8")
    place_piece(:black, :bishop, "f8")
    place_piece(:black, :king, "e8")
    place_piece(:black, :queen, "d8")
  end

  def check_engine(options)
    unless File.exist?(options[:engine_path])
      raise EngineNotFoundError, "Engine not found at #{options[:engine_path]}"
    end
    unless File.executable?(options[:engine_path])
      raise EngineNotExecutableError, "Engine at #{options[:engine_path]} is not executable"
    end
  end

  def set_debug(options)
    @debug = !!options[:debug]
  end

  def log(message)
    puts "DEBUG (#{engine_name}): #{message}" if @debug
  end

  def open_engine_connection(engine_path)
    @engine_stdin, @engine_stdout, @wait_thr = Open3.popen2e(engine_path)
  end

  def require_keys!(hash, *required_keys)
    required_keys.flatten.each do |required_key|
      if !hash.keys.include?(required_key)
        key_string = (required_key.is_a?(Symbol) ? ":#{required_key}" : required_key )
        raise MissingRequiredHashKeyError, "Hash key '#{key_string}' missing"
      end
    end
    true
  end

  def set_engine_name(options)
    if options[:name].to_s.size > 1
      @engine_name = options[:name]
    else
      @engine_name = options[:engine_path].split('/').last
    end
  end

  def default_options
    { :movetime => 100 }
  end
end

class UciError < StandardError; end
class MissingRequiredHashKeyError < StandardError; end
class EngineNotFoundError < UciError; end
class EngineNotExecutableError < UciError; end
class EngineNameMismatch < UciError; end
class ReturnStringError < UciError; end
class UnknownNotationExtensionError < UciError; end
class NoMoveError < UciError; end
class EngineResignError < NoMoveError; end
class NoPieceAtPositionError < UciError; end
class UnknownBestmoveSyntax < UciError; end
class FenFormatError < UciError; end
class BoardLockedError < UciError; end

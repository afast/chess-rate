require 'optparse'
require 'fileutils'

$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('lib', File.expand_path('uci-0.0.2', File.expand_path('..', File.dirname(__FILE__))))

require 'uci'
require 'open3'
require_relative 'db_ref'
require_relative 'fen_move.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: game_analyzer.rb [options]"
  opts.on("-f", "--file PATH", "File PATH") do |file_path|
    options[:file_path] = file_path
  end
  opts.on("-m", "--motor PATH", "Motor PATH") do |motor|
    options[:motor_path] = motor
  end
  opts.on("-p", "--pgn2fen PATH", "Pgn2fen PATH") do |pgn2fen|
    options[:pgn2fen_path] = pgn2fen
  end
  opts.on("-t", "--time [VALUE]", Integer, "Time to ponder each move") do |time|
    options[:time] = time || 300
  end
  opts.on("-d", "--draw [VALUE]", Float, "Draw threshold e.g.: 1.56") do |draw|
    options[:draw_threshold] = draw || 1.56
  end
  opts.on("-b", "--blunder [VALUE]", Float, "Blunder threshold e.g.: 2.56") do |blunder|
    options[:blunder_threshold] = blunder || 2
  end
  opts.on("--debug", "Debug") do |draw|
    options[:debug] = true
  end
end.parse!

class GameAnalyzer
  def initialize(games, motor_path, pgn2fen_path, time, games_path, tie_threshold, blunder_threshold, debug=nil)
    @games = games
    @motor_path = motor_path
    @time = time || 100
    @games_path = games_path
    @tie_threshold = tie_threshold || 1.56
    @blunder_threshold = blunder_threshold || 2
    @debug = debug || false
    @pgn2fen_path = pgn2fen_path
    @db_ref_full = []
  end

  def analyze_games
    @uci = Uci.new(:engine_path => @motor_path, movetime: @time, debug: @debug)

    @uci.wait_for_readyok
    board = Board::Game.new

    fileName = 'pgn/games_analyzed_' + @games_path.split('/').last
    unless File.directory?('pgn')
      FileUtils.mkdir_p('pgn')
    end
    outFile = File.new(fileName, "w")

    @games.each do |game|
      @uci.wait_for_readyok
      board.setup_board

      board_score = 0

      outFile.puts("[Event \"#{game.event}\"]")
      outFile.puts("[Site \"#{game.site}\"]")
      outFile.puts("[Date \"#{game.date}\"]")
      outFile.puts("[EndDate \"#{game.enddate}\"]")
      outFile.puts("[Round \"#{game.round}\"]")
      outFile.puts("[White \"#{game.white}\"]")
      outFile.puts("[Black \"#{game.black}\"]")
      outFile.puts("[Result \"#{game.result}\"]")
      outFile.puts("[Engine \"#{@uci.engine_name}\"]")
      old_move = game.moves.first
      old_lan_move = nil
      old_bestmove = nil
      old_score = nil
      player_out_of_db_ref = nil
      move_out_of_db_ref = nil
      value_out_of_db_ref = nil
      best_value_out_of_db_ref = nil
      deviation_out_of_db_ref = nil
      first_time_here = true

      @uci.send_position_to_engine

      game.moves.each_with_index do |move, index|
        lan_move = board.move move.move, move.side
        old_lan_move = lan_move if old_lan_move.nil?

        score, best_move = @uci.analyse_position
        if score.nil?
          score = old_score
        else
          score *= -1 if move.side == :black
        end
        old_score = score if old_score.nil?
        if old_lan_move == old_bestmove
          old_score = score
        elsif score > old_score && old_move.side == :white || score < old_score && old_move.side == :black
          old_bestmove = old_lan_move
          old_score = score
        end

        if index > 0
          puts "-------------------------------"
          puts "#{(index+1)/2}. #{old_move.side} #{old_lan_move} | #{old_bestmove}"
          puts "  Score (P/M): #{score} / #{old_score}"
          puts "-------------------------------"

          percentage, coincidences = getPercentage @uci.fenstring
          if coincidences == 0 && first_time_here
            player_out_of_db_ref = old_move.side
            move_out_of_db_ref = (index+1)/2
            value_out_of_db_ref = score
            best_value_out_of_db_ref = old_score
            deviation_out_of_db_ref = (score-old_score).abs
            first_time_here = false
          elsif coincidences > 0
            first_time_here = true
          end

          old_move.player_value = score
          old_move.annotator_value = old_score
          old_move.annotator_move = old_bestmove
        end

        old_score = score
        old_move = move
        old_lan_move = lan_move
        old_bestmove = best_move
        @uci.move_piece lan_move
        @uci.send_position_to_engine
      end
      old_move.player_value = old_score
      old_move.annotator_value = old_score
      old_move.annotator_move = old_bestmove

      outFile.puts("[WhiteAvgError \"#{'%.2f' % game.white_avg_deviation}\"]")
      outFile.puts("[WhiteStdDeviation \"#{'%.2f' % game.white_standard_deviation}\"]")
      outFile.puts("[WhitePerfectMoves \"#{'%.2f' % game.white_perfect_moves}\"]")
      outFile.puts("[WhiteBlunders \"#{'%.2f' % game.white_blunders(@tie_threshold, @blunder_threshold)}\"]")
      outFile.puts("[BlackAvgError \"#{'%.2f' % game.black_avg_deviation}\"]")
      outFile.puts("[BlackStdDeviation \"#{'%.2f' % game.black_standard_deviation}\"]")
      outFile.puts("[BlackPerfectMoves \"#{'%.2f' % game.black_perfect_moves}\"]")
      outFile.puts("[BlackBlunders \"#{'%.2f' % game.black_blunders(@tie_threshold, @blunder_threshold)}\"]")
      outFile.puts("[PlayerOutOfDB-Ref \"#{player_out_of_db_ref}\"]")
      outFile.puts("[MoveNumberOutOfDB-Ref \"#{move_out_of_db_ref}\"]")
      outFile.puts("[ValueOutOfDB-Ref \"#{'%.2f' % value_out_of_db_ref}\"]")
      outFile.puts("[ValueBestMoveOutOfDB-Ref \"#{'%.2f' % best_value_out_of_db_ref}\"]")
      outFile.puts("[DeviationOutOfDB-Ref \"#{'%.2f' % deviation_out_of_db_ref}\"]")
      outFile.puts(" ")
      game.moves.each { |m| outFile.puts m.to_s }
      outFile.puts(game.result)
      outFile.puts(" ")
    end
    outFile.close
    @uci.close_engine_connection
  end

  def pgn2fen(file_path)
    originalPath = String.new(file_path)
    originalPath.slice! ".pgn"
    @game_number_path = originalPath + "_GameNumber.txt"
    @bd_ref_path = originalPath + "_BD-REF.txt"
    @pgn_path = originalPath + ".pgn"
    @file_path = originalPath + ".txt"

    file = `wine "#{@pgn2fen_path}" "#{@pgn_path}"`
    txt_path_aux = String.new(@pgn_path)
    txt_path_aux.slice! ".pgn"
    txt_path = txt_path_aux + ".txt"
    outFile = File.open("#{txt_path}","w")
    outFile.puts(file)
    outFile.close
  end

  def add_game_number
    inFile = File.open(@file_path,"r")
    outFile = File.open(@game_number_path,"w")
    gameNumber = 0
    inFile.each do |line|
      fenArray = line.split(' ')
      if (fenArray[1].eql? 'w') && (fenArray[5].to_i==1)
        gameNumber += 1
      end
      newLine = line.chop + " " + gameNumber.to_s
      outFile.puts(newLine)
    end
    inFile.close
    outFile.close
  end

  def generate_DB_REF(file_path)
    pgn2fen file_path
    add_game_number

    nameDb = String.new(@pgn_path)
    nameDb.slice! ".pgn"
    nameDb = nameDb.split('/').last

    @db_ref = @db_ref_full.select{ |db| db.amI? nameDb }.first
    if @db_ref.nil?
      @db_ref = DbRef.new nameDb

      pgnFile = File.open(@pgn_path,"r")
      fenFile = File.open(@game_number_path,"r")
      finalFile = File.open(@bd_ref_path,"w")

      winner = "d"
      fenFile.each do |fenLine|
        match = fenLine.split(' ').last
        fenArray = fenLine.split(' ')
        if (fenArray[1].eql? 'w') && (fenArray[5].to_i==1)
          until (pgnLine = pgnFile.readline).start_with? '[Result '; end
          result = pgnLine.split('"')[1]
          if result.eql? '1-0'
            winner = "w"
          elsif result.eql? '0-1'
            winner = "b"
          else
            winner = "d"
          end
        end
        newLine = fenLine.chop + " " + winner
        finalFile.puts(newLine)

        fenmove = FenMove.new newLine.split(' ')[0], newLine.split(' ')[6], winner
        @db_ref.add_fen_move fenmove
      end

      @db_ref_full << @db_ref

      finalFile.close
      fenFile.close
      pgnFile.close
      return 'DB creada correctamente'
    else
      return 'DB ya existente'
    end
  end

  def deleteDB(db_name)
    @db_ref = @db_ref_full.select{ |db| db.amI? db_name }.first
    @db_ref_full.delete @db_ref
    return true
  end

  def setDB(db_name)
    @db_ref = @db_ref_full.select{ |db| db.amI? db_name }.first
  end

  def getPercentage(to_analyze)
    if @db_ref.nil?
      return -1, 0
    end
    return @db_ref.getPercentage to_analyze
  end

end

# loop do
#   puts "Move ##{uci.moves.size+1}."
#   puts uci.board # print ascii layout of current board.
#   uci.go!
# end

# load pgn and instantiate games
# analyze each game and annotate moves
# load info for each player

puts options.inspect

require 'parser'
require_relative '../board/game'

tree = Parser.parse File.read(options[:file_path])

# Print player ratings for each game
analyzer = GameAnalyzer.new tree.get_games, options[:motor_path], options[:pgn2fen_path], options[:time], options[:file_path],
  options[:draw_threshold], options[:blunder_threshold], options[:debug]

puts analyzer.generate_DB_REF '/home/andreas/personal/chess-rate/pgn/Power2013_2800plus.pgn'
analyzer.setDB 'Power2013_2800plus'

analyzer.analyze_games

require 'optparse'

$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('lib', File.expand_path('uci-0.0.2', File.expand_path('..', File.dirname(__FILE__))))

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: game_analyzer.rb [options]"
  opts.on("-f", "--file PATH", "File PATH") do |file_path|
    options[:file_path] = file_path
  end
  opts.on("-m", "--motor PATH", "Motor PATH") do |motor|
    options[:motor_path] = motor
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
end.parse!

require 'uci'

class GameAnalyzer
  def initialize(games, motor_path, time, games_path, tie_threshold, blunder_threshold)
    @games = games
    @motor_path = motor_path
    @time = time || 100
    @games_path = games_path
    @tie_threshold = tie_threshold || 1.56
    @blunder_threshold = blunder_threshold || 2
  end

  def analyze_games
    @uci = Uci.new(:engine_path => @motor_path, movetime: @time, debug: true)

    @uci.wait_for_readyok
    board = Board::Game.new

    fileName = '../pgn/games_analyzed_' + @games_path.split('/').last
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
      outFile.puts(" ")
      game.moves.each { |m| outFile.puts m.to_s }
      outFile.puts(game.result)
      outFile.puts(" ")
    end
    outFile.close
    @uci.close_engine_connection
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
analyzer = GameAnalyzer.new tree.get_games, options[:motor_path], options[:time], options[:file_path],
  options[:draw_threshold], options[:blunder_threshold]

analyzer.analyze_games

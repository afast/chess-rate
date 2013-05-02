require 'optparse'

$:.unshift File.dirname(__FILE__)

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
    options[:time] = time || 5
  end
  opts.on("-d", "--draw [VALUE]", Float, "Draw tolerance e.g.: 0.56") do |draw|
    options[:draw_tolerance] = draw || 0.6
  end
  opts.on("-b", "--blunder [VALUE]", Float, "Blunder tolerance e.g.: 0.56") do |blunder|
    options[:blunder_tolerance] = blunder || 5
  end
end.parse!

require 'uci'

class GameAnalyzer
  def initialize(games, motor_path, time)
    @games = games
    @motor_path = motor_path
    @time = time || 100
  end

  def analyze_games
    @uci = Uci.new(:engine_path => @motor_path, movetime: @time, 'UCI_AnalyseMode' => true)

    while !@uci.ready? do
      puts 'Waiting for motor ready'
      sleep(1)
    end
    move = @games.first.moves.first
    board = Board::Game.new
    @games.each do |game|
      @uci.new_game!
      @uci.ready?
      board.setup_board

      game.moves.each do |move|
        lan_move = board.move move.move, move.side
        puts "#{move.side} plays #{lan_move}"
        @uci.move_piece lan_move
        @uci.send_position_to_engine
        puts @uci.board
        unless move == game.moves.last
          best = @uci.bestmove
          puts best.inspect
        end
      end

      puts @uci.bestmove
      # evaluate each move
    end
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
analyzer = GameAnalyzer.new tree.get_games, options[:motor_path], options[:time]

analyzer.analyze_games

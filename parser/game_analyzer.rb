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
  def initialize(games, motor_path, time, games_path)
    @games = games
    @motor_path = motor_path
    @time = time || 100
    @games_path = games_path
  end

  def analyze_games
    @uci = Uci.new(:engine_path => @motor_path, movetime: @time, 'UCI_AnalyseMode' => true, multipv: 2)

    while !@uci.ready? do
      puts 'Waiting for engine ready'
      sleep(1)
    end
    move = @games.first.moves.first
    board = Board::Game.new

    fileName = "pgn/games_analyzed_"+@games_path.split("/").last
    outFile = File.new(fileName,"w")

    @games.each do |game|
      @uci.new_game!
      @uci.ready?
      board.setup_board

      board_score = 0
      
      outFile.puts("[Event "+game.event+"]")
      outFile.puts("[Site "+game.site+"]")
      outFile.puts("[Date "+game.date+"]")
      outFile.puts("[Round "+game.round+"]")   
      outFile.puts("[White "+game.white+"]")
      outFile.puts("[Black "+game.black+"]")
      outFile.puts("[Result "+game.result+"]") 
      outFile.puts("[Engine "+@uci.engine_name+"]")
      outFile.puts(" ")

      game.moves.each_with_index do |move, index|
        lan_move = board.move move.move, move.side

        player_scores = @uci.analyze_move(board_score, move.side == :white, lan_move)[0]

        scores, machine_move = @uci.analyze_move(board_score, move.side == :white)
        machine_score = scores[machine_move] || board_score

        # use calculated move or use the minimum between previous and new move
        # (some engines(e.g.: fruit) ignore the "searchmoves" directive
        if machine_move == lan_move
          board_score = machine_score
        else
          board_score = [player_scores[lan_move] || board_score, machine_score].min
        end

        puts "-------------------------------"
        puts "#{(index+2)/2}. #{move.side} #{lan_move} | #{machine_move}"
        puts "  Score (P/M): #{board_score} / #{machine_score}"
        puts "-------------------------------"

        if index % 2 == 0
          sideNotation = '.'
        else
          sideNotation = '...'
        end

        outFile.puts("#{(index+2)/2}#{sideNotation}#{lan_move} {#{board_score},#{machine_move},#{machine_score},#{(machine_score-board_score).abs}}")

        @uci.move_piece lan_move
        @uci.send_position_to_engine
      end
    outFile.puts(game.result)
    outFile.puts(" ")
    end
  outFile.close
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
analyzer = GameAnalyzer.new tree.get_games, options[:motor_path], options[:time], options[:file_path]

analyzer.analyze_games

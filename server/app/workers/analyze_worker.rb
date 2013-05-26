class AnalyzeWorker
  include Sidekiq::Worker

  def perform(pgn_file_id, time, tie_threshold, blunder_threshold)
    puts 'Analyzing!'
    puts "pgn_file #{pgn_file_id}"
    puts "time #{time}"
    puts "tie_threshold #{tie_threshold}"
    puts "blunder_threshold #{blunder_threshold}"

    tree = Parser.parse PgnFile.find(pgn_file_id).pgn_file.file.read

    # Print player ratings for each game
    analyzer = GameAnalyzer.new tree.get_games, time, tie_threshold, blunder_threshold

    analyzer.analyze_games
  end
end

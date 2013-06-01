class AnalyzeWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true

  def perform(pgn_file_id, time, tie_threshold, blunder_threshold)
    puts 'Analyzing!'
    puts "pgn_file #{pgn_file_id}"
    puts "time #{time}"
    puts "tie_threshold #{tie_threshold}"
    puts "blunder_threshold #{blunder_threshold}"

    puts "Loading file #{pgn_file_id}"
    pf = PgnFile.find(pgn_file_id)
    pf.start_processing
    puts 'Start parsing data...'
    tree = Parser.parse pf.pgn_file.file.read
    puts 'Finished Parsing'

    # Print player ratings for each game
    # analyzer = GameAnalyzer.new tree.get_games, time, tie_threshold, blunder_threshold

    games = tree.get_games
    pf.games.destroy_all
    pf.games = games
    pf.save
    games.each do |g|
      AnalyzeGameWorker.perform_async(g.id, time, tie_threshold, blunder_threshold)
    end
    pf.finished_processing
    puts 'Scheduled analysis for each game'
  end
end

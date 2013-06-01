class AnalyzeGameWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true

  def perform(game_id, time, tie_threshold, blunder_threshold)
    puts 'Analyzing!'
    puts "game #{game_id}"
    puts "time #{time}"
    puts "tie_threshold #{tie_threshold}"
    puts "blunder_threshold #{blunder_threshold}"

    game = Game.find(game_id)
    analyzer = GameAnalyzer.new [game], time, tie_threshold, blunder_threshold

    game.start_processing
    analyzer.analyze_games
    game.finished_processing
  end
end

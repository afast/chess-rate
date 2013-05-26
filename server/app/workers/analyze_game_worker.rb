class AnalyzeGameWorker
  include Sidekiq::Worker

  def perform(game_id, time, tie_threshold, blunder_threshold)
    puts 'Analyzing!'
    puts "game #{game_id}"
    puts "time #{time}"
    puts "tie_threshold #{tie_threshold}"
    puts "blunder_threshold #{blunder_threshold}"

    analyzer = GameAnalyzer.new Game.where(id: game_id), time, tie_threshold, blunder_threshold

    analyzer.analyze_games
  end
end

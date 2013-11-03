module PlotsHelper
  def game_perfect_plot_data(game)
    data = []
    if game.white_elo && game.white_perfect_rate
      data << {x: game.white_elo.to_i, y: game.white_perfect_rate}
    end
    if game.black_elo && game.black_perfect_rate
      data << {x: game.black_elo.to_i, y: game.black_perfect_rate}
    end
    data
  end

  def pgn_file_perfect_plot_data(pgn_file)
    pgn_file.games.processed.select([:white_elo, :black_elo, :white_perfect_rate, :black_perfect_rate]).map { |g| game_perfect_plot_data(g) }.flatten
  end

  def pgn_file_distance_plot_data(pgn_file)
    pgn_file.games.includes(:moves).processed.map { |g| game_distance_plot_data(g) }.flatten
  end

  def distance_plot_data(elo, moves)
    distance = moves.pluck(:distance).sum
    {x: elo, y: distance} if distance < 50
  end

  def game_distance_plot_data(game)
    data = []
    if game.white_elo
      data << distance_plot_data(game.white_elo, game.moves.white.not_perfect.select(:distance))
    end
    if game.black_elo
      data << distance_plot_data(game.black_elo, game.moves.black.not_perfect.select(:distance))
    end
    data.compact
  end
end

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
    pgn_file.games.processed.map { |g| game_perfect_plot_data(g) }.flatten
  end
end

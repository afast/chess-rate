module PlayersHelper
  def elo_data(player)
    [{
      values: player.games.sort { |i,j| i.start_date <=> j.start_date }.map { |g| {x: (g.start_date || Date.today).strftime('%Y-%m-%d'), y: g.get_elo_for(player.id).to_i}},
      key: t('elo_history'),
      color: '#ff7f0e'
    }]
  end

  def game_performance_data(player)
    values = {}
    player.moves.each do |m|
      values[m.number] ||= []
      values[m.number] << m.distance
    end
    [{
      values: values.map { |key, value| {x: key, y: (value.sum / value.size.to_f)} },
      key: t('game_progress'),
      color: '#ff7f0e'
    }]
  end
end

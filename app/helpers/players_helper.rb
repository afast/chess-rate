module PlayersHelper
  def elo_data(player)
    [{
      values: player.games.sort { |i,j| i.start_date <=> j.start_date }.map { |g| {x: (g.start_date || Date.today).strftime('%Y-%m-%d'), y: g.get_elo_for(player.id).to_i}},
      key: t('elo_history'),
      color: '#ff7f0e'
    }]
  end

  def game_performance_data(player)
    black_values = {}
    white_values = {}
    player.moves_black.each do |m|
      black_values[m.number] ||= []
      black_values[m.number] << m.distance
    end
    player.moves_white.each do |m|
      white_values[m.number] ||= []
      white_values[m.number] << m.distance
    end
    [{
      values: white_values.map { |key, value| {x: key, y: -(value.sum / value.size.to_f)} },
      key: t('white'),
      color: '#ff7f0e'
    },
    {
      values: black_values.map { |key, value| {x: key, y: -(value.sum / value.size.to_f)} },
      key: t('black'),
      color: '#000000'
    }]
  end

  def pretty_result(result)
    case result.to_s
    when '0' then t('lost')
    when '1' then t('won')
    when '1/2' then t('draw')
    when '0.5' then t('draw')
    end
  end
end

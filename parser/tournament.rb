class Tournament
  attr_reader :name, :start_date, :end_date

  def initialize(name, start_date, end_date)
    @name = name
    @start_date = start_date
    @end_date = end_date
    @games = []
  end

  def add_game(game)
    @games << game
  end

  def get_info_for(player_name)
    data = []
    @games.each do |game|
      info = game.get_info_for(player_name)
      data << info unless info.nil?
    end
    result = {}
    result[:avg_err] = (data.map{ |i| i[:avg_err] }.inject(:+) || 0) / data.size
    result[:std_dev] = (data.map{ |i| i[:std_dev] }.inject(:+) || 0) / data.size
    result[:perfect] = (data.map{ |i| i[:perfect] }.inject(:+) || 0) / data.size
    result[:blunders] = (data.map{ |i| i[:blunders] }.inject(:+) || 0) / data.size
    result
  end

  def match?(game)
    @name == game.name &&
      @start_date == game.date &&
      @end_date == game.enddate
  end
end

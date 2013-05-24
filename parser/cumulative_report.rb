require 'optparse'

$:.unshift File.dirname(__FILE__)

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: cumulative_report.rb [options]"
  opts.on("-f", "--file PATH", "File PATH") do |file_path|
    options[:file_path] = file_path
  end
  opts.on("-p", "--player [VALUE]", String, "Player to extract info about") do |player|
    options[:player] = player
  end
end.parse!

require 'tournament'

class CumulativeReport
  def initialize(games, player)
    @games = games
    @player = player
    @tournaments = []
  end

  def create_report
    @tournaments = []
    @games.each do |game|
      tournament = @tournaments.select { |t| t.match?(game) }.first
      if tournament.nil?
        tournament = Tournament.new game.event, game.date, game.enddate
        @tournaments << tournament
      end
      tournament.add_game game
    end
  end

  def print
    print = [['Event', 'Start Date', 'End Date', 'Avg Error', 'Std Deviation', 'Perfect %', 'Blunder %']]
    print += @tournaments.map do |t|
      r = t.get_info_for(@player)
      [t.name, t.start_date, t.end_date, r[:avg_err].to_s, r[:std_dev].to_s, (r[:perfect]*100).to_s, (r[:blunders]*100).to_s]
    end
    m = Array.new(print.map { |_| _.length }.max)
    print.each { |_| _.each_with_index { |e, i| s = e.size; m[i] = s if m[i].nil? || s > m[i] } }
    print.each { |x| puts m.map { |_| "%#{_}s" }.join(" " * 5) % x }
  end
end

puts options.inspect

require 'parser'
require_relative '../board/game'

tree = Parser.parse File.read(options[:file_path])

# Print player ratings for each game
cumulative_report = CumulativeReport.new tree.get_games, options[:player]

cumulative_report.create_report
cumulative_report.print

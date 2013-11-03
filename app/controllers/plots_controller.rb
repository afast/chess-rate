class PlotsController < ApplicationController
  include PlotsHelper

  def perfect
    @data = PgnFile.includes(:games).processed.map do |file|
      {key: file.description, values: pgn_file_perfect_plot_data(file)}
    end.delete_if { |f| f[:values].empty? }
    render :chart
  end

  def distance
    @data = PgnFile.includes(:games).processed.map do |file|
      {key: file.description, values: pgn_file_distance_plot_data(file)}
    end.delete_if { |f| f[:values].empty? }
    render :chart
  end
end

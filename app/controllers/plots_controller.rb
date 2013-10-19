class PlotsController < ApplicationController
  include PlotsHelper

  def perfect
    @data = PgnFile.processed.map do |file|
      {key: file.description, values: pgn_file_perfect_plot_data(file)}
    end.delete_if { |f| f[:values].empty? }
  end
end

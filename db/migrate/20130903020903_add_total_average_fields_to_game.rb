class AddTotalAverageFieldsToGame < ActiveRecord::Migration
  def change
    add_column :games, :total_average_error, :float
    add_column :games, :total_perfect_rate, :float
  end
end

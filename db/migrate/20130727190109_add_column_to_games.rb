class AddColumnToGames < ActiveRecord::Migration
  def change
    add_column :games, :player_out_db_ref, :string
    add_column :games, :move_out_db_ref, :integer
    add_column :games, :value_out_db_ref, :decimal
    add_column :games, :best_value_out_db_ref, :decimal
    add_column :games, :deviation_out_db_ref, :decimal
  end
end

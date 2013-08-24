class AddGameIdToMove < ActiveRecord::Migration
  def change
    add_column :moves, :game_id, :integer
  end
end

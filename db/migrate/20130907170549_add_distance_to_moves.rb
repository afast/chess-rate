class AddDistanceToMoves < ActiveRecord::Migration
  def change
    add_column :moves, :distance, :float
  end
end

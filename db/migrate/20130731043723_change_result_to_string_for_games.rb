class ChangeResultToStringForGames < ActiveRecord::Migration
  def up
    change_column :games, :result, :string
  end

  def down
    change_column :games, :result, :integer
  end
end

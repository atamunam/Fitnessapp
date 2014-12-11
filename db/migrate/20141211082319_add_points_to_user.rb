class AddPointsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :points, :integer
  	add_column :users, :points_at_stake, :integer
  end
end

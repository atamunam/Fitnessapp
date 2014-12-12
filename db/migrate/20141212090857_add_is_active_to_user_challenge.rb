class AddIsActiveToUserChallenge < ActiveRecord::Migration
  def change
  	add_column :user_challenges, :is_active, :boolean
  end
end

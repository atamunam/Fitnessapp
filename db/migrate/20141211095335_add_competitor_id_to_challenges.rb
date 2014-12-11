class AddCompetitorIdToChallenges < ActiveRecord::Migration
  def change
  	add_column :challenges, :competitor_id, :integer
  end
end

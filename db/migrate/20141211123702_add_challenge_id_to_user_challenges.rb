class AddChallengeIdToUserChallenges < ActiveRecord::Migration
  def change
  	add_column :user_challenges, :challenge_id, :integer
  end
end

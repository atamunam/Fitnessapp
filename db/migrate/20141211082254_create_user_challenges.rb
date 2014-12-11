class CreateUserChallenges < ActiveRecord::Migration
  def change
    create_table :user_challenges do |t|
      t.integer :user_id
      t.integer :competitor_id
      t.boolean :is_approved
      t.boolean :is_completed
      t.boolean :is_accepted
      t.boolean :is_winner

      t.timestamps
    end
  end
end

class Challenge < ActiveRecord::Base
  validates :points, presence: true
  validates :title, presence: true

  belongs_to :user
end

json.array!(@challenges) do |challenge|
  json.extract! challenge, :id, :title, :description, :user_id, :start_date, :end_date, :points
  json.url challenge_url(challenge, format: :json)
end

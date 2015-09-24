namespace :counter_cache do
  desc "reset counter_cache for all models"
  task reset_all: :environment do
    Choice.find_each { |choice| Choice.reset_counters(choice.id, :votes) }
    Poll.find_each   { |poll| poll.update_columns(total_votes: poll.votes.count) }
  end
end

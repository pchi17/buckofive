namespace :counter_cache do
  desc "reset counter_cache for all models"
  task reset_all: :environment do
    Choice.find_each { |c| Choice.reset_counters(c.id, :votes) }
  end
end

namespace :mec_events do
  task :verify_participation_confirmation_limit => :environment do
    EventConfiguration.verify_participation_confirmation_limit
  end
end

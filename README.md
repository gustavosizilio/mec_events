CRON CONFIGURATION
-- Configure CRON to run the following job every begining of day.
cd APPLICATION_PATH && rake mec_events:verify_participation_confirmation_limit RAILS_ENV="production"

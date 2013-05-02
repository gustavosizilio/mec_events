every '00-59/1 * * * * root' do
  #TODO try to get redmine path  
  command "cd #{path}/../../ && rake mec_events:verify_participation_confirmation_limit"
end

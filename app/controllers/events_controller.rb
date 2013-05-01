class EventsController < ApplicationController
  before_filter :find_issue, :authorize

  # Send invitations for users
  def send_invitations
    
    @issues = []
    @errors = []
    @event_configuration = EventConfiguration.find_by_issue(@issue)
    EventConfiguration.get_participants(@issue).each do |user|
      principal = Principal.find(user.id)
      issue = Issue.where(:parent_id => @issue, :assigned_to_id => principal, :tracker_id => @event_configuration.participation_tracker).first
      issue ||= Issue.new
      
      if issue.new_record? 
        issue.parent_issue_id = @issue.id
        issue.author = @issue.author
        issue.assigned_to_id = principal.id

        issue.subject = "Teste"
        issue.project = @issue.project
        issue.tracker = @event_configuration.participation_tracker
      end
      if issue.save
        #TO-DO...
      else
        #TO-DO catch errors
        @errors << issue.errors.full_messages
      end
    end

    redirect_to issue_path(@issue)
  end
end

class EventsController < ApplicationController
  before_filter :find_issue, :authorize

  # Send invitations for users
  def new_invitations_with_confirmation
  end

  def send_invitations
    @errors = EventConfiguration.create_participants @issue, params
    redirect_to issue_path(@issue)
  end

  def confirm_invitation
    begin
      EventConfiguration.confirm(@issue)
    rescue
      flash[:error] = l(:update_status_fail) 
    end
    redirect_to issue_path(@issue)
  end

  def configure_daily_and_passages
  end

  def update_daily_and_passages
    EventConfiguration.update_daily_and_passages(@issue, params)
    redirect_to issue_path(@issue)
  end 
end

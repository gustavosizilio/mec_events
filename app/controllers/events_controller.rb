class EventsController < ApplicationController
  before_filter :find_issue, :authorize

  # Send invitations for users
  def send_invitations
    redirect_to issue_path(@issue)
  end
end

class EventConfigurationController < ApplicationController
  menu_item :settings
  before_filter :find_project, :authorize

  # Create or update a project's event configuration
  def edit
    @event_configuration = EventConfiguration.where(:project_id => @project.id).first
    @event_configuration ||= EventConfiguration.new(:project => @project)

    @event_configuration.safe_attributes = params[:event_configuration]

    @event_configuration.save if request.post?
  end
end

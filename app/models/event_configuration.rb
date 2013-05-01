class EventConfiguration < ActiveRecord::Base
  include Redmine::SafeAttributes  
  belongs_to :event_tracker, :class_name => Tracker
  belongs_to :participation_tracker, :class_name => Tracker
  belongs_to :custom_field_participants, :class_name => IssueCustomField
  belongs_to :project

  safe_attributes 'event_tracker_id',
    'participation_tracker_id',
    'project_id',
    'custom_field_participants_id'

  def self.find_by_issue issue
    EventConfiguration.where(:project_id => issue.project.id).last
  end

  def self.tracker? issue
    @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
    return false if @event_configuration.nil?
    return @event_configuration.event_tracker_id == issue.tracker.id;
  end

  def self.get_participants issue
    @participants = []
    @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
    return @participants if @event_configuration.nil?
    
    if(issue.available_custom_fields.include?(@event_configuration.custom_field_participants))
      @custom_field_participants_value = issue.custom_field_values.select { |cv|
        cv.custom_field_id == @event_configuration.custom_field_participants_id
      }[0]

      unless(@custom_field_participants_value.nil?)
        @custom_field_participants_value.value.each do |participant_id|
          @participants << User.find(participant_id) 
        end 
      end
    end
    @participants
  end
end

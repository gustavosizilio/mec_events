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

end

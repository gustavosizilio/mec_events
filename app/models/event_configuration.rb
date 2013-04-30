class EventConfiguration < ActiveRecord::Base
  include Redmine::SafeAttributes  
  belongs_to :event_issue_category, :class_name => IssueCategory
  belongs_to :participation_issue_category, :class_name => IssueCategory
  belongs_to :project

  safe_attributes 'event_issue_category_id',
    'participation_issue_category_id',
    'project_id'

end

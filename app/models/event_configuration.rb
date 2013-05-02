class EventConfiguration < ActiveRecord::Base
  include Redmine::SafeAttributes  
  belongs_to :event_tracker, :class_name => Tracker
  belongs_to :participation_tracker, :class_name => Tracker
  belongs_to :custom_field_participants, :class_name => IssueCustomField
  belongs_to :custom_field_require_participation_confirmation, :class_name => IssueCustomField
  belongs_to :project

  safe_attributes 'event_tracker_id',
    'participation_tracker_id',
    'project_id',
    'custom_field_participants_id',
    'participation_subject_template',
    'custom_field_require_participation_confirmation_id'

  EVENT_SUBJECT_PLACEHOLDER = "{%event_subject%}"

  def build_subject issue
    self.participation_subject_template.gsub EVENT_SUBJECT_PLACEHOLDER, issue.subject if self.participation_subject_template
  end
  
  def self.create_participants issue
    @errors = []
    event_configuration = EventConfiguration.find_by_issue(issue)
    event_configuration.get_participants(issue).each do |user|
      principal = Principal.find(user.id)
      new_issue = Issue.where(:parent_id => issue, :assigned_to_id => principal, :tracker_id => event_configuration.participation_tracker).first
      new_issue ||= Issue.new

      if new_issue.new_record? 
        new_issue.parent_issue_id = issue.id
        new_issue.author = Principal.find(User.current.id)
        new_issue.assigned_to_id = principal.id
        new_issue.project = issue.project
        new_issue.subject = event_configuration.build_subject(issue)
        new_issue.tracker = event_configuration.participation_tracker
      end
      if new_issue.save
        #TO-DO...
      else
        puts new_issue.errors.full_messages
        #TO-DO catch errors
        @errors << new_issue.errors.full_messages
      end
    end
    @errors
  end

  def self.find_by_issue issue
    EventConfiguration.where(:project_id => issue.project.id).last
  end

  def self.require_confirmation? issue
    @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
    return false if @event_configuration.nil?

    if(issue.available_custom_fields.include?(@event_configuration.custom_field_require_participation_confirmation))
      @require_confirmation_value = issue.custom_field_values.select { |cv|
        cv.custom_field_id == @event_configuration.custom_field_require_participation_confirmation_id
      }[0]
      return @require_confirmation_value.value == '1'
    end
      
    return false
  end

  def self.tracker? issue
    @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
    return false if @event_configuration.nil?
    return @event_configuration.event_tracker_id == issue.tracker.id;
  end

  def get_participants issue
    @participants = []
    
    if(issue.available_custom_fields.include?(self.custom_field_participants))
      @custom_field_participants_value = issue.custom_field_values.select { |cv|
        cv.custom_field_id == self.custom_field_participants_id
      }[0]

      unless(@custom_field_participants_value.nil?)
        @custom_field_participants_value.value.each do |participant_id|
          @participants << User.find(participant_id) 
        end 
      end
    end
    @participants
  end


  def self.verify_participation_confirmation_limit
    `echo AAAAAAAAAAAAAAAAAAAAAAAAAAAAAHAUHSUHSAUHSUAHUSHUAHSU >> /home/gustavo/test2.txt`
  end
end

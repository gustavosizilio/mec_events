#TODO validations...
class EventConfiguration < ActiveRecord::Base
  include Redmine::SafeAttributes  
  belongs_to :event_tracker, :class_name => Tracker
  belongs_to :participation_tracker, :class_name => Tracker
  belongs_to :custom_field_participants, :class_name => IssueCustomField
  belongs_to :custom_field_require_participation_confirmation, :class_name => IssueCustomField
  belongs_to :custom_field_require_daily_and_passages, :class_name => IssueCustomField
  belongs_to :custom_field_participation_confirmation_limit, :class_name => IssueCustomField
  belongs_to :custom_field_daily_and_passages_value, :class_name => IssueCustomField
  belongs_to :participation_start_status, :class_name => IssueStatus
  belongs_to :participation_expired_confirmation_status, :class_name => IssueStatus
  belongs_to :participation_confirmed_status, :class_name => IssueStatus

  belongs_to :project

  safe_attributes 'event_tracker_id',
    'participation_tracker_id',
    'project_id',
    'custom_field_participants_id',
    'participation_subject_template',
    'custom_field_require_participation_confirmation_id',
    'custom_field_participation_confirmation_limit_id',
    'participation_start_status_id',
    'participation_expired_confirmation_status_id',
    'participation_confirmed_status_id',
    'custom_field_require_daily_and_passages_id',
    'custom_field_daily_and_passages_value_id'

  EVENT_SUBJECT_PLACEHOLDER = "{%event_subject%}"

  def build_subject issue
    self.participation_subject_template.gsub EVENT_SUBJECT_PLACEHOLDER, issue.subject if self.participation_subject_template
  end
  
  def self.update_daily_and_passages issue, params
    @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
    @issue = Issue.find(issue.id)
    cv = @event_configuration.get_custom_value @issue, @event_configuration.custom_field_daily_and_passages_value_id

    pjson = params
    pjson.select! { |k, v| 
      k == :passages.to_s || k == :request_funding_type.to_s
    }
    
    pjson[:passages] = pjson[:passages].values if !pjson[:passages].nil? && !pjson[:passages].empty?

    if(pjson[:request_funding_type.to_s] == :daily_only.to_s || pjson[:request_funding_type.to_s] == '')
      pjson[:passages] = []
    end

    if cv.nil? 
      cv = CustomValue.new
      cv.customized_type = "Issue"
      cv.customized_id = @issue.id
      cv.custom_field_id = @event_configuration.custom_field_daily_and_passages_value_id
    end
    cv.value = pjson.to_json()
    cv.save
  end

  def self.get_daily_and_passages_value issue, key
     @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
     cv = @event_configuration.get_custom_value issue, @event_configuration.custom_field_daily_and_passages_value_id
    r = nil     
    unless cv.nil?
      begin
        r = JSON.parse cv.value 
      rescue
        return ""
      end
    end
    r[key]
  end

  def self.create_participants issue, params
    @errors = []
    event_configuration = EventConfiguration.find_by_issue(issue)
    event_configuration.get_participants(issue).each do |user|
      principal = Principal.find(user.id)
      new_issue = Issue.where(:parent_id => issue, :assigned_to_id => principal, :tracker_id => event_configuration.participation_tracker).first
      new_issue ||= Issue.new

      
      #cv_confirmation_limit = @event_configuration.get_custom_value(new_issue, event_configuration.custom_field_participation_confirmation_limit_id)
    
      if new_issue.new_record? 
        new_issue.parent_issue_id = issue.id
        new_issue.author = Principal.find(User.current.id)
        new_issue.assigned_to_id = principal.id
        new_issue.project = issue.project
        new_issue.subject = event_configuration.build_subject(issue)
        new_issue.tracker = event_configuration.participation_tracker
        new_issue.status_id = event_configuration.participation_start_status_id
        if params[:issue] && params[:issue][:participation_confirmation_limit]
           cv_confirmation_limit = CustomValue.new(:custom_field_id => event_configuration.custom_field_participation_confirmation_limit_id, :customized => new_issue, :value => params[:issue][:participation_confirmation_limit])
           new_issue.custom_values.push(cv_confirmation_limit) 
        end
      end
      if new_issue.save
        #cv_confirmation_limit.save
        #TODO: verify post save needs
      else
        puts new_issue.errors.full_messages
        #TODO catch errors
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
      @require_confirmation_value = @event_configuration.get_custom_value(issue, @event_configuration.custom_field_require_participation_confirmation_id)
      return @require_confirmation_value.value == '1'
    end
      
    return false
  end

  def self.can_confirm? issue
    EventConfiguration.issues_to_confirm(issue.project, User.current).where("issues.id = #{issue.id}").all.size > 0
  end
  
  def self.confirm issue
        @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
        @issue = Issue.find(EventConfiguration.issues_to_confirm(issue.project, User.current).find(issue.id).id)
        @issue.status = @event_configuration.participation_confirmed_status
        @issue.save
  end

  def self.issues_to_confirm project, user
      ec = EventConfiguration.where(:project_id => project.id).last

      Issue.where(:tracker_id => ec.participation_tracker_id, :project_id => ec.project_id, :status_id => ec.participation_start_status_id )
      .joins('LEFT OUTER JOIN issues father ON father.id = issues.parent_id')
      .joins('LEFT OUTER JOIN custom_values father_custom_values ON father_custom_values.customized_id = father.id')
      .where("father_custom_values.custom_field_id=#{ec.custom_field_require_participation_confirmation_id}")
      .where("father_custom_values.value = '1' ")
      .joins('LEFT OUTER JOIN custom_values ON custom_values.customized_id = issues.id')
      .where("custom_values.custom_field_id=#{ec.custom_field_participation_confirmation_limit_id}")
      .where("custom_values.value >= '#{DateTime.now.strftime("%F")}' OR custom_values.value = ''")
      .where("issues.assigned_to_id = #{user.id}")
      .where("issues.status_id = #{ec.participation_start_status_id}")
  end

  def get_custom_value issue, custom_field_id
    issue.custom_values.select { |cv|
        cv.custom_field_id == custom_field_id
    }[0]
  end

  def self.event_tracker? issue
    @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
    return false if @event_configuration.nil?
    return @event_configuration.event_tracker_id == issue.tracker.id;
  end

  def self.participation_tracker? issue
    @event_configuration = EventConfiguration.where(:project_id => issue.project.id).last
    return false if @event_configuration.nil?
    return @event_configuration.participation_tracker_id == issue.tracker.id;
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
    ec_with_confirmation = EventConfiguration.where('custom_field_require_participation_confirmation_id > 0')
    ec_with_confirmation.each do |ec|
      Issue.where(:tracker_id => ec.participation_tracker_id, :project_id => ec.project_id, :status_id => ec.participation_start_status_id )
      .joins('LEFT OUTER JOIN issues father ON father.id = issues.parent_id')
      .joins('LEFT OUTER JOIN custom_values father_custom_values ON father_custom_values.customized_id = father.id')
      .where("father_custom_values.custom_field_id=#{ec.custom_field_require_participation_confirmation_id}")
      .where("father_custom_values.value = '1' ")
      .joins('LEFT OUTER JOIN custom_values ON custom_values.customized_id = issues.id')
      .where("custom_values.custom_field_id=#{ec.custom_field_participation_confirmation_limit_id}")
      .where("custom_values.value < '#{DateTime.now.strftime("%F")}' ")
      .update_all(["issues.status_id=?", ec.participation_expired_confirmation_status_id])
    end
  end

  def self.request_funding_types
    [:daily_and_passages, :daily_only, :passages_only]
  end

  def self.can_update_daily_and_passages? issue
    ec = EventConfiguration.where(:project_id => issue.project.id).last
    issue.status_id == ec.participation_confirmed_status_id
  end

end

class AddParticipationSubjectTemplateToEventConfiguration < ActiveRecord::Migration
  def up
    add_column :event_configurations, :participation_subject_template, :string
  end

  def down
    remove_column :event_configurations, :participation_subject_template
  end
end

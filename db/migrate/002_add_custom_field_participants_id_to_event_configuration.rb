class AddCustomFieldParticipantsIdToEventConfiguration < ActiveRecord::Migration
  def up
    add_column :event_configurations, :custom_field_participants_id, :integer
  end

  def down
    remove_column :event_configurations, :custom_field_participants_id
  end
end

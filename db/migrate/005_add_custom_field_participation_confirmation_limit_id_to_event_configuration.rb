class AddCustomFieldParticipationConfirmationLimitIdToEventConfiguration < ActiveRecord::Migration
  def up
    add_column :event_configurations, :custom_field_participation_confirmation_limit_id, :integer
  end

  def down
    remove_column :event_configurations, :custom_field_participation_confirmation_limit_id
  end
end

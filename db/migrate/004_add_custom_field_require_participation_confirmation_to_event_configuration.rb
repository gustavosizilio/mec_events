class AddCustomFieldRequireParticipationConfirmationToEventConfiguration < ActiveRecord::Migration
  def up
  add_column :event_configurations, :custom_field_require_participation_confirmation_id, :integer
  end

  def down
    remove_column :event_configurations, :custom_field_require_participation_confirmation_id
  end
end

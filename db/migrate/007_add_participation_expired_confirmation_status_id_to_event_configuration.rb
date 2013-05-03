class AddParticipationExpiredConfirmationStatusIdToEventConfiguration < ActiveRecord::Migration
  def up
    add_column :event_configurations, :participation_expired_confirmation_status_id, :integer
  end

  def down
    remove_column :event_configurations, :participation_expired_confirmation_status_id
  end
end

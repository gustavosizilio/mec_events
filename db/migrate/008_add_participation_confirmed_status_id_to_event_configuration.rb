class AddParticipationConfirmedStatusIdToEventConfiguration < ActiveRecord::Migration
  def up
    add_column :event_configurations, :participation_confirmed_status_id, :integer
  end

  def down
    remove_column :event_configurations, :participation_confirmed_status_id
  end
end

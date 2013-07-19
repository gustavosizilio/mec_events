class AddCustomFieldRequireDailyAndPassagesToEventConfiguration < ActiveRecord::Migration
  def up
    add_column :event_configurations, :custom_field_require_daily_and_passages_id, :integer
  end

  def down
    remove_column :event_configurations, :custom_field_require_daily_and_passages_id
  end
end

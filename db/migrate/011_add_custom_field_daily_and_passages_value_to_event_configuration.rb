class AddCustomFieldDailyAndPassagesValueToEventConfiguration < ActiveRecord::Migration
  def up
    add_column :event_configurations, :custom_field_daily_and_passages_value_id, :integer
  end

  def down
    remove_column :event_configurations, :custom_field_daily_and_passages_value_id
  end
end

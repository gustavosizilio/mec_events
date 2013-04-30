class CreateEventConfigurations < ActiveRecord::Migration
  def change
    create_table :event_configurations do |t|
      t.integer :event_issue_category_id
      t.integer :participation_issue_category_id
      t.integer :project_id, :references => :project
    end
  end
end

class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.column :issue_id, :integer
      t.column :comment, :string
      t.column :date, :datetime
      t.column :alert_watchers, :integer
      t.column :alert_project_members, :integer
      t.column :alert_project_members, :integer
      t.column :alert_author, :integer
      t.column :author_id, :integer
      t.column :created_on, :datetime
    end
  end

  def self.down
    drop_table :alerts
  end
end
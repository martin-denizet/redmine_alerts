class CreateAlertSubscribers < ActiveRecord::Migration
  def self.up
    create_table :alert_subscribers do |t|
      t.column :user_id, :integer
      t.column :alert_id, :integer
    end
  end

  def self.down
    drop_table :alert_subscribers
  end
end

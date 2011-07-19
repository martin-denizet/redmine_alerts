class CreateAlertSubcribers < ActiveRecord::Migration
  def self.up
    create_table :alert_subcribers do |t|
      t.column :user_id, :integer
      t.column :alert_id, :integer
    end
  end

  def self.down
    drop_table :alert_subcribers
  end
end

class Alert < ActiveRecord::Base
  unloadable

  has_one :author, :class_name => 'User', :foreign_key => 'author_id'

  has_many :subscriptions, :class_name => "AlertSubscribers",
    :foreign_key => "alert_id"

  has_many :subscribers, :class_name => "User", :through => :subscriptions,
    :foreign_key => "user_id", :source => :user
  

  def unit
    1
  end

  def method
    1
  end

  def get_all_subscribers
    users=[]
    self.subscribers.each{|subscriber|
      users << subscriber
    }
    if self.alert_watchers
      users << self.issue.watcher_users
    end
    if self.alert_project_members
      users << self.issue.project.users
    end
    users.uniq
  end

  def subscribed
    !AlertSubscribers.find(:first,:conditions=>["user_id = ? AND alert_id = ?", User.current.id, self.id]).nil?
  end

end

class Alert < ActiveRecord::Base
  unloadable

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  belongs_to :issue, :class_name => 'Issue', :foreign_key => 'issue_id'

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
    if self.subscribers
        users += self.subscribers
    end

    if self.alert_watchers
        users += self.issue.watcher_users
    end

    if self.alert_project_members
        users += self.issue.project.users
    end

    users.uniq
  end

  def subscribed
    !AlertSubscribers.find(:first,:conditions=>["user_id = ? AND alert_id = ?", User.current.id, self.id]).nil?
  end

  def time_left
    self.date-DateTime.now
  end

  def time_left_absolute
    time_left.abs
  end

  def completed?
    self.sent_on!=nil
  end

  def hot?
    time_left_absolute < 20.minutes
  end

  def css_class
    self.hot? ? "hot": self.completed? ? "completed" : ""
  end

end

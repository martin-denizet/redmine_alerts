class Alert < ActiveRecord::Base
  unloadable

  has_one :author, :class_name => 'User', :foreign_key => 'author_id'

  has_many :subscribers, :class_name => "AlertSubscribers",
    :foreign_key => "alert_id"

end

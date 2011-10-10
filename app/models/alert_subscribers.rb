class AlertSubscribers < ActiveRecord::Base
  unloadable

  belongs_to :user

  belongs_to :alert

end

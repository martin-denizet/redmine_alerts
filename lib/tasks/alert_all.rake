desc <<-END_DESC
Send alerts configured with the Alert plugin.

Available options:
  * delta     => number of minutes to trigger alert in advance (defaults to 5)

Example:
  rake redmine:send_alerts_all delta=15 RAILS_ENV="production"
END_DESC
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment.rb")
require "mailer"

class Alert_all < Mailer
  def alert_all(user,alert)
    puts "Sending email to "+user.to_s+"("+user.mail+")"
    set_language_if_valid user.language
    recipients "martin.denizet@irec.cn" #user.mail
    subject l(:alert_email_subject, {:issue => '#'+alert.issue.id.to_s,:reason => alert.comment})
    body :alert => alert, :issue => Issue.find(alert.issue_id), :issue_url => {
      :controller => 'issue',
      :action => "show",
      :id => alert.issue_id
    }
    render_multipart('alert', body)

    alert.sent_on = DateTime.now
    alert.save
    
  end
  def self.alerts_all(options={})
    delta = options[:delta] || 5

    trigger_date = (delta.to_i).minute.from_now
    puts "Alerts before "+trigger_date.to_s+" deta="+delta.to_s+" minute(s)"

    alerts=Alert.find(:all,:conditions=>["date < ? AND sent_on IS NULL",trigger_date])

    puts alerts.size.to_s+" Alerts triggered"

    alerts.each{|alert|
      puts "Processing Alert '"+alert.id.to_s+"' Alert date:"+alert.date.to_s
      users = alert.get_all_subscribers
      #select only the active users
      users = users.select {|user| user.status==1}
      users.each{|user|
        deliver_alert_all(user,alert)
      }
    }
  end
end

namespace :redmine do
  task :send_alerts_all => :environment do
    options = {}
    options[:delta] = ENV['delta'].to_i if ENV['delta']
    puts "Init "+DateTime.now.to_s
    Alert_all.alerts_all(options)
    puts "End "+DateTime.now.to_s
  end
end
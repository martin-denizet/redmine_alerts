# To change this template, choose Tools | Templates
# and open the template in the editor.

def time_units
  [[l(:label_alert_minutes), 1], [l(:label_alert_hours), 2], [l(:label_alert_day), 3], [l(:label_alert_weeks), 4], [l(:label_alert_month), 5], [l(:label_alert_year), 6]]
end

def timing
  [[l(:label_after_now), 1], [l(:label_from_start_date), 2], [l(:label_from_due_date), 3], [l(:label_after_start_date), 4], [l(:label_after_due_date), 5]]
end

def get_alerts_by_issue(issue_id)
  Alert.find(:all,:conditions=>["issue_id=?"+(Setting.plugin_redmine_alerts['alerts_hide_completed'].to_i == 1 ? "and sent_on IS NULL" : ""),
      issue_id],
    :order => 'date ASC'
  )
end

def get_alerts_by_user(user_id)

  return Alert.find(:all,
    #:select => "#{Alert.table_name}.*, #{Issue.table_name}.subject, #{Issue.table_name}.id, #{User.table_name}.*",
    :conditions => ["("+
        "(#{Alert.table_name}.alert_watchers=1 AND #{Watcher.table_name}.user_id=?) OR "+
        "(#{Alert.table_name}.alert_project_members=1 AND #{Member.table_name}.user_id=?) OR" +
        "(#{AlertSubscribers.table_name}.user_id=?)
    )"+
        " AND #{Alert.table_name}.sent_on IS NULL",
      user_id, user_id, user_id
    ],
    :include => [ :issue, :author, :subscribers ],
    :joins => "LEFT OUTER JOIN #{Member.table_name} ON #{Member.table_name}.project_id = #{Issue.table_name}.project_id"+
      " LEFT OUTER JOIN #{Watcher.table_name} ON #{Watcher.table_name}.watchable_id = #{Issue.table_name}.id AND (#{Watcher.table_name}.watchable_type='Issue')",
    :group => "#{Alert.table_name}.id",
    :order => "#{Alert.table_name}.date ASC")
  
end

def get_alerts_excluding_user(user_id)

  return Alert.find(:all,
    :conditions => ["(NOT ("+
        "(#{Alert.table_name}.alert_watchers=1 AND #{Watcher.table_name}.user_id=?) OR "+
        "(#{Alert.table_name}.alert_project_members=1 AND #{Member.table_name}.user_id=?) OR" +
        "(#{AlertSubscribers.table_name}.user_id IS NOT NULL AND #{AlertSubscribers.table_name}.user_id=?)
    ))"+
        " AND #{Alert.table_name}.sent_on IS NULL",
      user_id, user_id, user_id
    ],
    :include => [ :issue, :author, :subscribers ],
    :joins => "LEFT OUTER JOIN #{Member.table_name} ON #{Member.table_name}.project_id = #{Issue.table_name}.project_id"+
      " LEFT OUTER JOIN #{Watcher.table_name} ON #{Watcher.table_name}.watchable_id = #{Issue.table_name}.id AND (#{Watcher.table_name}.watchable_type='Issue')",
    :group => "#{Alert.table_name}.id",
    :order => "#{Alert.table_name}.date ASC")

end
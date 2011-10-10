module AlertsHelper

#  def time_units
#    [['Minutes', 1], ['Hours', 2], ['Days', 3], ['Days', 4], ["Weeks", 5], ["Months", 6], ["Years", 7]]
#  end
#
#  def timing
#    [['From now', 1], ['After due date', 2], ['After start date', 3]]
#  end
  
  def get_alerts_by_issue(issue_id)
    Alert.find(:all,:conditions=>["issue_id=?"+Setting.plugin_redmine_alerts['alerts_hide_completed'].to_i == 1 ? "and sent_on = NULL" : "",
        issue_id])
  end

  def link_to_if_authorized_globally(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if authorized_globally(options[:controller],options[:action])
      link_to(name, options, html_options, *parameters_for_method_reference)
    end
  end

  def authorized_globally(controller,action)
    User.current.allowed_to?({:controller => controller, :action => action},nil, :global => true)
  end

  def alerts_index()
    link_to l(:label_alerts), url_for(:controller => 'alerts', :action=>'index')
  end
end

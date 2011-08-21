module AlertsPlugin
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_sidebar_issues_bottom(context={ })
      # the controller parameter is part of the current params object
      # This will render the partial into a string and return it.
      context[:controller].send(:render_to_string, {
          :partial => "hooks/alerts/view_issues_sidebar_queries_bottom",
          :locals => context
        })
      # render_on :view_issues_sidebar_planning_bottom, :partial => "issues/contacts", :locals => {:contact_issue => @issue}

      # Instead of the above statement, you could return any string generated
      # by your code. That string will be included into the view
    end

  end
end
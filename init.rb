require 'redmine'

# Customization hooks
# It requires the file in redmine_alerts/hooks/hooks
require 'redmine_alerts/hooks/hooks'
require 'redmine_alerts/const'

Redmine::Plugin.register :redmine_alerts do
  name 'Redmine Alerts plugin'
  author 'Martin Denizet'
  description 'Allow to create configurable, time-based alerts'
  version '0.1.0'
  url 'https://github.com/martin-denizet/redmine_alerts'
  author_url 'https://github.com/martin-denizet'

  project_module :alerts do
    permission :view_alerts, {:alerts => :index}
    permission :add_alerts, {:alerts => :new}
    permission :edit_alerts, {:alerts => :edit}
    permission :edit_own_alerts, {:alerts => :edit_own}
    permission :delete_own_alerts, {:alerts => :destroy_own}
    permission :delete_alerts, {:alerts => :destroy}
    permission :view_all_alerts, {:alerts => [:index,:index_all] }
  end

  menu :top_menu, :alerts, { :controller => 'alerts', :action => 'index' }, :caption => :label_alerts,
    :if =>  Proc.new {
		User.current.allowed_to?({ :controller => 'alerts', :action => 'index' }, nil, :global => true)
	}

  settings :default => {
    'alerts_hide_completed' => "0"
  }, :partial => 'settings/alerts_settings'

  RAILS_DEFAULT_LOGGER.info "Alerts plugin initialized"
end

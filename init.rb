require 'redmine'


# Customization hooks
# It requires the file in redmine_alerts/hooks/hooks
require 'redmine_alerts/hooks/hooks'


Redmine::Plugin.register :redmine_alerts do
  name 'Redmine Alerts plugin'
  author 'Martin Denizet'
  description 'This is a plugin for Redmine'
  version '0.0.1-dev'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

end

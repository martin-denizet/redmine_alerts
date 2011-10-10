Redmine Alerts Plugin
=====================

This is a Redmine plugin that enables to set configurable alerts to be reminded of an issue.

Features
--------

* Alerts defined on a datetime or relative to the issue Start date or Due date
* Countdown to alert
* Possible to subscribe to alerts or to alert the issue's watchers or project members
* MyPage integration
* Global permissions

Roadmap
-------

* Alerts without related issue
* Outlook integration

Installation
------------

First setup the plugin:

    cd /var/www/redmine/vendors/plugins
    git clone git://github.com/martin-denizet/redmine_alerts.git
    cd /var/www/redmine
    rake db:migrate_plugins

Define a crontab:

    */10 * * * * cd /var/www/redmine && rake redmine:send_alerts_all delta=5 RAILS_ENV=production

Remove the plugin
-----------------

    cd /var/www/redmine
    rake db:migrate_plugins PLUGIN=redmine_alerts VERSION=0 RAILS_ENV=production

License
-------

Published under GPLv2

Known Issues
------------

* The delta parameter of the rake task cannot be specified
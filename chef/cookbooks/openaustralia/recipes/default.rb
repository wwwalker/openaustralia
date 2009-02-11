#
# Cookbook Name:: openaustralia
# Recipe:: default
#

package "git"

# Container for all the web applications
directory "/www" do
  owner "matthewl"
  group "matthewl"
  mode 0755
  action :create
end

directory "/www/www.openaustralia.org" do
  owner "matthewl"
  group "matthewl"
  mode 0755
  action :create
end

# Hmmm... I wonder if Apache will start up if the openaustralia app is not installed
link "/www/www.openaustralia.org/html" do
  to "openaustralia/current/twfy/www/docs"
end

# Configuration for OpenAustralia web app
remote_file "/www/www.openaustralia.org/openaustralia/shared/general" do
  source "general"
  owner "matthewl"
  group "matthewl"
end

package "apache" do
  source "ports:apache22"
end

# Need to specify the build option for the php5 package below
remote_file "/var/db/ports/php5/options" do
  source "php5.ports.options"
  mode 0644
  owner "root"
  group "wheel"
end

# Need to build php5 from ports to select the option for building mod_php
package "php5" do
  source "ports"
end

remote_file "/usr/local/etc/apache22/httpd.conf" do
  source "httpd.conf"
  mode 0644
  owner "root"
  group "wheel"
end

service "apache22" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
  subscribes :reload, resources('remote_file[/usr/local/etc/apache22/httpd.conf]'), :immediately
end
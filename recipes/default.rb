#
# Cookbook Name::chef-sensu-community-plugins
# Recipe:: default
#
# Copyright 2012, Ulf Mansson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "git"

git node[:chef_sensu_community_plugins][:path] do
  repository node[:chef_sensu_community_plugins][:repository]
  reference node[:chef_sensu_community_plugins][:reference]
  action :sync
end

link "#{node['sensu']['directory']}/plugins/sensu-community-plugins" do
    to "#{node[:chef_sensu_community_plugins][:path]}/plugins"
end

link "#{node['sensu']['directory']}/handlers/sensu-community-plugins" do
    to "#{node[:chef_sensu_community_plugins][:path]}/handlers"
end

link "#{node['sensu']['directory']}/mutators/sensu-community-plugins" do
    to "#{node[:chef_sensu_community_plugins][:path]}/mutators"
end

link "#{node['sensu']['directory']}/extensions/sensu-community-plugins" do
    to "#{node[:chef_sensu_community_plugins][:path]}/extensions"
end
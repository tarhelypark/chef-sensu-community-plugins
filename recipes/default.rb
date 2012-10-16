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

include_recipe "git"

git "/opt/sensu-community-plugins" do
  repository "https://github.com/sensu/sensu-community-plugins.git"
  reference "1860721b049d32397f4605bff93c049c049f9f7e"
  action :sync
end

link "#{node['sensu']['directory']}/plugins/sensu-community-plugins" do
    to "/opt/sensu-community-plugins/plugins"
end

link "#{node['sensu']['directory']}/handlers/sensu-community-plugins" do
    to "/opt/sensu-community-plugins/handlers"
end

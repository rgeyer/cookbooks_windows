#
# Cookbook Name:: rl_tests
# Recipe:: remote_recipe_pong
#
#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

Chef::Log.info("Entering Pong")

if(!node[:rl_tests])
  Chef::Log.info("(FAIL) Expecting node[:rl_tests] to be populated, but it was null")
else
  Chef::Log.info("(PASS) node[:rl_tests] has contents")
  if(!node[:rl_tests][:one] || node[:rl_tests][:one] != "1")
    Chef::Log.info("(FAIL) Expecting node[:rl_tests][:one] == 1 but it was either unset, or != 1")
  else
    Chef::Log.info("(PASS) node[:rl_tests][:one] == #{node[:rl_tests][:one]}")
  end
  if(!node[:rl_tests][:two] || node[:rl_tests][:two] != "2")
    Chef::Log.info("(FAIL) Expecting node[:rl_tests][:two] == 2 but it was either unset, or != 2")
  else
    Chef::Log.info("(PASS) node[:rl_tests][:two] == #{node[:rl_tests][:two]}")
  end
end

if(!node[:foo])
  Chef::Log.info("(FAIL) Expected node[:foo] to be populated but it was null")
end

if(!node[:baz])
  Chef::Log.info("(FAIL) Expected node[:foo] to be populated but it was null")
end
#
# Cookbook Name:: rl_tests
# Recipe:: remote_recipe_test
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

send_hash = {
  :rl_tests => {
    :one => "1",
    :two => "2"
  },
  :foo => "bar",
  :baz => "nothing"
}

Chef::Log.info("Sending the following hash to rl_tests::remote_recipe_ping on the first server with the tag rl_tests:target=true")

remote_recipe "Ping" do
  recipe "rl_tests::remote_recipe_ping"
  attributes(send_hash)
  recipients_tags ["rl_tests:target=true"]
  scope :single
end
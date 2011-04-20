#
# Cookbook Name:: mnt_utils
# Recipe:: determine_architecture
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

node[:mnt_utils][:arch] = `echo %PROCESSOR_ARCHITECTURE%`.strip
node[:mnt_utils][:system32_dir] = node[:mnt_utils][:arch] =~ /x86/ ? ::File.join(ENV["windir"], "system32") : ::File.join(ENV["windir"], "Sysnative")

Chef::log.info("The processor architecture of this Windows instance is #{node[:mnt_utils][:arch]}")
Chef::log.info("All 32bit built in windows executables can be found at #{node[:mnt_utils][:system32_dir]}")
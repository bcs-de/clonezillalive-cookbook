#
# Cookbook Name:: clonezillalive
# Recipe:: server
#
# Copyright 2013, Arnold Krille for bcs kommunikationsloesungen
#                 <a.krille@b-c-s.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe('pxe::default')

package 'unzip'

include_recipe('nfs::server')

checksums = {
  '2.2.1-25-amd64' => 'e112cf43b0a53fc4b29f6f7c7e949d0b',
  '2.2.1-25-i486' => '416dc627af28aa25814490cfdbd55f83',
  '2.2.1-25-i686-pae' => 'c47d1bd39bd252eb6dd3da101fc4bdd9'
}

checksum = node['clonezilla']['checksum']
if checksum == ''
  checksum = checksums[
    "#{node['clonezilla']['version']}-#{node['clonezilla']['architecture']}"
  ]
end

czfile = node['clonezilla']['file']
if czfile == ''
  czfile = "clonezilla-live-#{node['clonezilla']['version']}-" \
    "#{node['clonezilla']['architecture']}.zip"
end
czurl = node['clonezilla']['url']
if czurl == ''
  czurl = "http://sourceforge.net/projects/clonezilla/files/" \
    "clonezilla_live_stable/#{node['clonezilla']['version']}/" \
    "#{czfile}/download"
end

## Clonezilla image
#
['clonezilla'].each do |dir|
  directory "#{node['tftp']['directory']}/#{dir}" do
    action :create
    mode 0755
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/#{czfile}" do
  source czurl
  checksum checksum
  mode 00644
  not_if do
    ::File.exists?("#{Chef::Config[:file_cache_path]}/#{czfile}")
  end
end

bash 'unpack_clonezilla' do
  user 'root'
  cwd "#{node['tftp']['directory']}/clonezilla"
  code "unzip -j #{Chef::Config[:file_cache_path]}/#{czfile} " \
    'live/vmlinuz live/initrd.img live/filesystem.squashfs -d .'
  not_if { ::File.exists?("#{node['tftp']['directory']}/clonezilla/vmlinuz") }
end

## boot-menu
#
appendline = "#{node['clonezilla']['append_line']} " \
             "keyboard-layouts=#{node['clonezilla']['kbdlayout']}"
if node['clonezilla']['debug_boot']
  appendline = "#{appendline} nosplash"
else
  appendline = "#{appendline} quiet"
end

ocs_prerun1 = "sudo mount -t nfs #{node['clonezilla']['serverip']}:" \
  "/media/clonezilla /home/partimag"
fetch = \
  "tftp://#{node['clonezilla']['serverip']}/clonezilla/filesystem.squashfs"

pxe_menu 'clonezillalive-restoredisk' do
  section 'clonezilla'
  label 'CZ Restore Disk'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{appendline} ocs_prerun1=\"#{ocs_prerun1} -o ro\" " \
    "ocs_live_run=\"ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true " \
    "restoredisk ask_user ask_user\" ocs_live_extra_param=\"\" " \
    "ocs_live_batch=\"yes\" " \
    "fetch=#{fetch}"
end

pxe_menu 'clonezilla-restoreparts' do
  section 'clonezilla'
  label 'CZ Restore Partitions'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{appendline} ocs_prerun1=\"#{ocs_prerun1} -o ro\" " \
    "ocs_live_run=\"ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true " \
    "restoreparts ask_user ask_user\" ocs_live_extra_param=\"\" " \
    "ocs_live_batch=\"yes\" " \
    "fetch=#{fetch}"
end

pxe_menu 'clonezillalive' do
  section 'clonezilla'
  label 'Clonezilla Live'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{appendline} ocs_prerun1=\"#{ocs_prerun1} -o rw\" " \
    "ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" " \
    "ocs_postrun1=\"sleep 10\" ocs_live_batch=\"no\" " \
    "fetch=#{fetch}"
end

## nfs part
#
['clonezilla', 'clonezilla/disk'].each do |dir|
  directory "/media/#{dir}" do
    action :create
    mode 00755
    owner 'root'
    group 'root'
  end
end

nfs_export '/media/clonezilla' do
  network '*'
  writeable true
  sync false
  options ['no_root_squash', 'hide', 'nocrossmnt', 'no_subtree_check']
end

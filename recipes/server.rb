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

## Clonezilla image
#
['clonezilla'].each do |dir|
  directory "#{node['tftp']['directory']}/#{dir}" do
    action :create
    mode 0755
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/#{node['clonezilla']['file']}" do
  source "#{node['clonezilla']['url']}"
  checksum "#{node['clonezilla']['checksum']}"
  mode 00644
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/#{node['clonezilla']['file']}") }
end

bash 'unpack_clonezilla' do
  user 'root'
  cwd "#{node['tftp']['directory']}/clonezilla"
  code "unzip -j #{Chef::Config[:file_cache_path]}/#{node['clonezilla']['file']} " \
    'live/vmlinuz live/initrd.img live/filesystem.squashfs -d .'
  not_if { ::File.exists?("#{node['tftp']['directory']}/clonezilla/vmlinuz") }
end

## boot-menu
#

if node['clonezilla']['debug_boot']
  node.set['pxe']['appendline'] = "#{node['pxe']['appendline']} nosplash"
else
  node.set['pxe']['appendline'] = "#{node['pxe']['appendline']} quiet"
end

pxe_menu 'clonezillalive-restoredisk' do
  section 'clonezilla'
  label 'CZ Restore Disk'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{node['pxe']['appendline']} ocs_prerun1=\"sudo mount -t nfs " \
    "#{node['clonezilla']['serverip']}:/media/clonezilla /home/partimag -o ro\" " \
    "ocs_live_run=\"ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true " \
    "restoredisk ask_user ask_user\" ocs_live_extra_param=\"\" " \
    "ocs_live_batch=\"yes\" " \
    "fetch=tftp://#{node['clonezilla']['serverip']}/clonezilla/filesystem.squashfs"
end

pxe_menu 'clonezilla-restoreparts' do
  section 'clonezilla'
  label 'CZ Restore Partitions'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{node['pxe']['appendline']} ocs_prerun1=\"sudo mount -t nfs " \
    "#{node['clonezilla']['serverip']}:/media/clonezilla /home/partimag -o ro\" " \
    "ocs_live_run=\"ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true " \
    "restoreparts ask_user ask_user\" ocs_live_extra_param=\"\" " \
    "ocs_live_batch=\"yes\" " \
    "fetch=tftp://#{node['clonezilla']['serverip']}/clonezilla/filesystem.squashfs"
end

pxe_menu 'clonezillalive' do
  section 'clonezilla'
  label 'Clonezilla Live'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{node['pxe']['appendline']} ocs_prerun1=\"sudo mount -t nfs " \
    "#{node['clonezilla']['serverip']}:/media/clonezilla /home/partimag -o rw\" " \
    "ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" " \
    "ocs_postrun1=\"sleep 10\" ocs_live_batch=\"no\" " \
    "fetch=tftp://#{node['clonezilla']['serverip']}/clonezilla/filesystem.squashfs"
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

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
tftpdir = node['tftp']['directory']

package 'unzip'

node.default['nfs']['service']['portmap'] = 'rpcbind'
include_recipe('nfs::server')

czver = '2.1.2-43'
czzip = "clonezilla-live-#{czver}-i686-pae.zip"
czurl = 'http://sourceforge.net/projects/clonezilla/files/' \
        "clonezilla_live_stable/#{czver}/#{czzip}/download"

## Clonezilla image
#
['clonezilla'].each do |dir|
  directory "#{tftpdir}/#{dir}" do
    action :create
    mode 0755
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/#{czzip}" do
  source czurl
  checksum '3ab39169a1fdbdc89e61b943e8a7f39374babd53'
  mode 00644
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/#{czzip}") }
end

bash 'unpack_clonezilla' do
  user 'root'
  cwd "#{tftpdir}/clonezilla"
  code "unzip -j #{Chef::Config[:file_cache_path]}/#{czzip} " \
    'live/vmlinuz live/initrd.img live/filesystem.squashfs -d .'
  not_if { ::File.exists?("#{tftpdir}/clonezilla/vmlinuz") }
end

## boot-menu
#
serverip = node['clonezilla']['serverip'] || node['ipaddress']

appendline = 'boot=live config noswap nolocales edd=on nomodeset noprompt ' \
             "keyboard-layouts=#{node['clonezilla']['kbdlayout']}"
if node['clonezilla']['debug_boot']
  appendline = "#{appendline} nosplash"
else
  appendline = "#{appendline} quiet"
end

pxe_menu 'clonezillalive-restoredisk' do
  section 'clonezilla'
  label 'CZ Restore Disk'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{appendline} ocs_prerun1=\"sudo mount -t nfs " \
    "#{serverip}:/media/clonezilla /home/partimag -o ro\" " \
    'ocs_live_run=\"ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true ' \
    'restoredisk ask_user ask_user\" ocs_live_extra_param=\"\" ' \
    'ocs_live_batch=\"yes\" ' \
    "fetch=tftp://#{serverip}/clonezilla/filesystem.squashfs"
end

pxe_menu 'clonezilla-restoreparts' do
  section 'clonezilla'
  label 'CZ Restore Partitions'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{appendline} ocs_prerun1=\"sudo mount -t nfs " \
    "#{serverip}:/media/clonezilla /home/partimag -o ro\" " \
    'ocs_live_run=\"ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true ' \
    'restoreparts ask_user ask_user\" ocs_live_extra_param=\"\" ' \
    'ocs_live_batch=\"yes\" ' \
    "fetch=tftp://#{serverip}/clonezilla/filesystem.squashfs"
end

pxe_menu 'clonezillalive' do
  section 'clonezilla'
  label 'Clonezilla Live'
  kernel 'clonezilla/vmlinuz'
  initrd 'clonezilla/initrd.img'
  append "#{appendline} ocs_prerun1=\"sudo mount -t nfs " \
    "#{serverip}:/media/clonezilla /home/partimag -o rw\" " \
    'ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" ' \
    'ocs_postrun1=\"sleep 10\" ocs_live_batch=\"no\" ' \
    "fetch=tftp://#{serverip}/clonezilla/filesystem.squashfs"
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

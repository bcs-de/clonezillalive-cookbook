# Default NFS options
default['nfs']['service']['portmap'] = 'rpcbind'

# Default PXE options
default['pxe']['appendline'] = 'boot=live config noswap nolocales edd=on nomodeset noprompt keyboard-layouts=us'

# Default tftp options
default['tftp']['directory'] = "#{node['tftp']['directory']}"

# IP of this server for the clients to use. Default is node['ipaddress'].
# If you want this to be different, override it in your wrapper cookbook.
default['clonezilla']['serverip'] = "#{node['ipaddress']}"

# Whether to show lots of output during boot or not.
default['clonezilla']['debug_boot'] = false

# Which version of Clonezilla are we installing? If you wrap ['url']['fqdn'], you have to duplicate the values
# that depend on it as well. That's how chef rolls.
default['clonezilla']['version'] = '2.1.2-43'
default['clonezilla']['file'] = "clonezilla-live-#{node['clonezilla']['version']}-i686-pae.zip"
default['clonezilla']['url'] = 'http://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/' \
                                "#{node['clonezilla']['version']}/#{node['clonezilla']['file']}/download"

# Clonezilla download checksum
default['clonezilla']['checksum'] = '3ab39169a1fdbdc89e61b943e8a7f39374babd53'
# Default NFS options
default['nfs']['service']['portmap'] = 'rpcbind'

# Default PXE options
default['clonezilla']['append_line'] = \
  'boot=live config noswap nolocales edd=on nomodeset noprompt'
default['clonezilla']['kbdlayout'] = 'us'

# Default tftp options, notice we are setting "dir".
# This is due to the pxe cookbook asking for that. Must be old code.
default['tftp']['dir'] = node['tftp']['directory']

# IP of this server for the clients to use. Default is node['ipaddress'].
# If you want this to be different, override it in your wrapper cookbook.
default['clonezilla']['serverip'] = node['ipaddress']

# Whether to show lots of output during boot or not.
default['clonezilla']['debug_boot'] = false

# Which version of Clonezilla are we installing? If you wrap ['url']['fqdn'],
# you have to duplicate the values that depend on it as well. That's how chef
# rolls. Version info, checksums, etc can be found at the URL:
# http://clonezilla.org/downloads.php
default['clonezilla']['version'] = '2.2.1-25'
default['clonezilla']['architecture'] = 'i686-pae'
default['clonezilla']['checksum'] = ''
default['clonezilla']['file'] = ''
default['clonezilla']['url'] = ''

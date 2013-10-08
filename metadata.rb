name             'clonezillalive'
maintainer       'bcs kommunikationsloesungen'
maintainer_email 'Arnold Krille <a.krille@b-c-s.de>'
license          'Apache License, Version 2.0'
description      'Installs/Configures clonezillalive'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

provides         'clonezillalive::default'
provides         'clonezillalive::server'

attribute        'clonezilla/serverip',
                 :display_name => 'Server IP',
                 :description => 'Set a special ip for the clients to use when booting. For example if your server lives in two networks and clients should use the second interfaces ip-address. node[\'ipaddress\'] is used if this is unset.',
                 :type => 'string',
                 :required => 'optional',
                 :default => nil

supports         'debian', '>= 7.0'

depends          'tftp'
depends          'nfs'

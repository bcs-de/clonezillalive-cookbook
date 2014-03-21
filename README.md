clonezillalive Cookbook
=======================

Deploy Clonezilla-Live for network-booting.

Clonezilla then allows to save and restore images of hard-disks.

If the image is for windows and prepared for example with sysprep, it can be
used to install several machines over and over again.

Requirements
------------

The development of this cookbook happens on debian wheezy (7.x), which makes
this the supported platform. It should work on ubuntu too.

#### cookbooks
 - `pxe`: For the booting and creation of the pxe-menu
 - `nfs`: For the image store

Attributes
----------

#### node\['clonezilla'\]\['append\_line'\] = 'boot=live config noswap nolocales edd=on nomodeset noprompt'
Basic appendline to boot. Will be extended by the keyboard-layout and the specific options to run clonezilla.

#### node\['clonezilla'\]\['kbdlayout'\] = 'us'
Set the keyboard-layout to use in clonezilla.

#### node\['clonezilla'\]\['serverip'\] = nil
If the server is reachable via two (or more) interfaces, use the given address
for the clients to boot from. If not given, node\['ipaddress'\] is used. 

#### node\['clonezilla'\]\['debug\_boot'\] = false
By default clonezilla boots with `quiet` added to the appendline. With this attribute set to `true`, `quiet` is replaced by `nosplash`.

#### node\['clonezilla'\]\['version'\] = '2.2.1-25'
The version of clonezilla to install.

#### node\['clonezilla'\]\['architecture'\] = 'i686-pae'
The processor architecture to use for the clonezilla netboot. Can be different from the servers own architecture. Clonezilla has images for 'i486', 'i686-pae' and 'amd64'.

#### node\['clonezilla'\]\['checksum'\] = '&lt;checksum\_of\_2.2.1-25&gt;'
The corresponding md5-checksum of the clonezilla-version to verify the download. Unless you change the version for clonezilla to a version not yet incorporated in this recipe, there should be no need to set this attribute.

#### node\['clonezilla'\]\['file'\]
Customized name of the file to download. Defaults to `clonezilla-live-#{node['clonezilla']['version']}-{#node['clonezilla']['architecture']}.zip`. Unless you want to download a custom clonezilla (from a custom location) there should be no need to set this attribute.

#### node\['clonezilla'\]\['url'\]
Customized download url. Defaults to `http://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/#{node['clonezilla']['version']}/#{node['clonezilla']['file']}/download`. Unless you want to download a custom clonezilla (from a custom location) there should be no need to set this attribute.

Usage
-----
#### clonezillalive::default

This recipe does nothing. Its there to play it safe if I want to add providers
and resources to this cookbook.

#### clonezillalive::server

This recipe grabs the clonezilla live image and unpacks the files needed for
network-boot. Then it installs tftp and syslinux and configures pxe-booting for
the clonezilla image.

Contributing
------------

Standard opensource cookbook rules apply:

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Run `rubocop` and `foodcritic .` and try to have not to many issues.
5. <del>Write tests for your change (if applicable)</del>
6. <del>Run the tests, ensuring they all pass</del>
7. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Arnold Krille (for bcs kommunikationslösungen)

Contributors: Brent Stephens (Outloud Industries, LLC)

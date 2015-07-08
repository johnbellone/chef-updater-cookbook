#
# Cookbook: chef-updater
# License: Apache 2.0
# Copyright (C) 2015 Bloomberg Finance L.P.
#
chef_updater node['chef-updater']['package_name'] do
  package_source node['chef-updater']['package_source']
  package_version node['chef-updater']['package_version']
  package_checksum node['chef-updater']['package_checksum']
end

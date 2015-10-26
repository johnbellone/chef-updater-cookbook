#
# Cookbook: chef-updater
# License: Apache 2.0
#
# Copyright 2015, Bloomberg Finance L.P.
#
chef_updater node['chef-updater']['package_name'] do
  base_url node['chef-updater']['base_url']
  package_version node['chef-updater']['package_version']
  package_checksum node['chef-updater']['package_checksum']
  package_source node['chef-updater']['package_source']
end.run_action(:upgrade)

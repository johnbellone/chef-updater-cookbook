#
# Cookbook: chef-updater
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
include_recipe 'chef-sugar::default'

at_compile_time do
  ruby_block 'Abort Chef Convergence' do
    block { throw :end_client_run_early }
    action :nothing
  end

  chef_updater node['chef-updater']['package_name'] do
    base_url node['chef-updater']['base_url']
    package_version node['chef-updater']['package_version']
    package_checksum node['chef-updater']['package_checksum']
    package_source node['chef-updater']['package_source']
    timeout node['chef-updater']['timeout'] if node['chef-updater']['timeout']
  end
end

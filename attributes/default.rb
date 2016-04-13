#
# Cookbook: chef-updater
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
if platform?('windows')
  default['chef-updater']['package_name'] = 'chef-client'
else
  default['chef-updater']['package_name'] = 'chef'
end

default['chef-updater']['package_version'] = '12.8.1-1'
default['chef-updater']['package_source'] = nil

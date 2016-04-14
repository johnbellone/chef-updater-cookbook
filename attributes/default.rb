#
# Cookbook: chef-updater
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
default['chef-updater']['package_name'] = if platform?('windows')
                                            'chef-client'
                                          else
                                            'chef'
                                          end

default['chef-updater']['package_version'] = '12.9.38-1'
default['chef-updater']['package_source'] = nil

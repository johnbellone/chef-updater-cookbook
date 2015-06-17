#
# Cookbook: chef-updater
# License: Apache 2.0
# Copyright (C) 2015 Bloomberg Finance L.P.
#

if defined?(ChefSpec)
  def create_chef_updater(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_updater, :create, resource_name)
  end
end

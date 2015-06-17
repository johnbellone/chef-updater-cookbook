#
# Cookbook: chef-updater
# License: Apache 2.0
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise'
require 'uri'

class Chef::Resource::ChefUpdater < Chef::Resource
  include Poise(fused: true)
  provides(:chef_updater)

  attribute(:package_name, kind_of: String, name_attribute: true)
  attribute(:package_source, kind_of: [NilClass, String, Array], default: nil)
  attribute(:package_checksum, kind_of: [NilClass, String], default:nil)
  attribute(:package_version, kind_of: [NilClass, String], default: nil)

  action(:upgrade) do
    notifying_block do
      location = new_resource.package_source
      if location =~ URI::regexp
        location = remote_file ::File.join(Chef::Config[:file_cache_path], ::File.basename(location)) do
          source location
          checksum new_resource.package_checksum unless new_resource.package_checksum.nil?
          action :create_if_missing
        end.path
      end

      package new_resource.package_name do
        version new_resource.package_version unless new_resource.package_version.nil?
        source location unless location.nil?
        action :upgrade
        notifies :run, 'ruby_block[Abort Chef Client]', :immediately
      end

      # TODO: (jbellone) Use a Chef handler here to report which
      # clients upgraded.  We are going to want to know this
      # information.

      ruby_block 'Abort Chef Client' do
        block { Chef::Application.fatal!('Chef client has been upgraded; aborting the run!') }
        action :nothing
      end
    end
  end
end

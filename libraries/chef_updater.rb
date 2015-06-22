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
      location = if location =~ /\A#{URI::regexp}\z/
                   remote_file ::File.join(Chef::Config[:file_cache_path], ::File.basename(location)) do
                     source location
                     checksum new_resource.package_checksum unless new_resource.package_checksum.nil?
                     action :create_if_missing
                   end.path
                 else
                   new_resource.package_source
                 end

      package new_resource.package_name do
        allow_downgrade true
        provider Chef::Provider::Package::Dpkg if node['platform'] == 'ubuntu'
        version new_resource.package_version unless new_resource.package_version.nil?
        source location unless location.nil?
        action :upgrade
        notifies :run, 'ruby_block[Abort Chef Client Early]', :immediately
      end

      # TODO: (jbellone) Use a Chef handler here to report which
      # clients upgraded.  We are going to want to know this
      # information.

      ruby_block 'Abort Chef Client Early' do
        block { throw :end_client_run_early }
        action :nothing
      end
    end
  end
end

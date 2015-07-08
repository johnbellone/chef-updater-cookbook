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
  default_action(:upgrade)

  attribute(:package_name, kind_of: String, name_attribute: true)
  attribute(:package_source, kind_of: [NilClass, String, Array], default: nil)
  attribute(:package_checksum, kind_of: [NilClass, String], default:nil)
  attribute(:package_version, kind_of: [NilClass, String], default: nil)

  # Determines the correct version string for platform families.
  # @return [String]
  def friendly_version
    if node['platform'] == 'redhat'
      [package_version, "el#{node['platform_version'].to_i}"].join('.')
    else
      package_version
    end
  end

  action(:upgrade) do
    notifying_block do
      location = if new_resource.package_source =~ /\A#{URI::regexp}\z/
                   basename = ::File.basename(new_resource.package_source)
                   remote_file ::File.join(Chef::Config[:file_cache_path], basename) do
                     source new_resource.package_source
                     checksum new_resource.package_checksum unless new_resource.package_checksum.nil?
                     action :create_if_missing
                   end.path
                 else
                   new_resource.package_source
                 end

      package new_resource.package_name do
        provider Chef::Provider::Package::Dpkg if node['platform'] == 'ubuntu'
        version new_resource.friendly_version unless new_resource.package_version.nil?
        source location unless location.nil?
        notifies :run, 'ruby_block[Abort Chef Convergence]', :immediately
      end

      # TODO: (jbellone) Use a Chef handler here to report which
      # clients upgraded.  We are going to want to know this
      # information.

      ruby_block 'Abort Chef Convergence' do
        block { throw :end_client_run_early }
        action :nothing
      end
    end
  end
end

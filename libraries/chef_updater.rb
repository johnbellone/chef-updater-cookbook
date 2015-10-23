#
# Cookbook: chef-updater
# License: Apache 2.0
#
# Copyright 2015, Bloomberg Finance L.P.
#
require 'poise'
require 'uri'

module ChefUpdaterCookbook
  module Resource
    class ChefUpdater < Chef::Resource
      include Poise(fused: true)
      provides(:chef_updater)

      attribute(:package_name, kind_of: String, name_attribute: true)
      attribute(:package_checksum, kind_of: String)
      attribute(:package_source, kind_of: String)
      attribute(:package_version, kind_of: String)

      def friendly_version
        return nil unless package_version
        case node['platform']
        when 'redhat', 'centos'
          [package_version, "el#{node['platform_version'].to_i}"].join('.')
        when 'fedora'
          [package_version, "fc#{node['platform_version'].to_i}"].join('.')
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
            version new_resource.friendly_version
            provider Chef::Provider::Package::Dpkg if platform?('ubuntu')
            if platform?('solaris2')
              provider Chef::Provider::Package::Solaris
              action :install
            else
              action :upgrade
            end
            notifies :run, 'ruby_block[Abort Chef Convergence]', :immediately
          end

          ruby_block 'Abort Chef Convergence' do
            block { throw :end_client_run_early }
            action :nothing
          end
        end
      end
    end
  end
end

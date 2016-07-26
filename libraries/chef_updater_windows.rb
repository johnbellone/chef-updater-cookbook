#
# Cookbook: chef-updater
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'
require 'uri'

module ChefUpdaterCookbook
  module Provider
    # A `chef_updater` provider which updates the Chef Client on the
    # Windows platform.
    # @provides chef_updater
    # @action run
    # @since 1.2
    class ChefUpdaterWindows < Chef::Provider
      include Poise
      provides(:chef_updater, os: 'windows')

      def action_run
        requested_package_version = new_resource.package_version.split('-').first
        return if chef_version.satisfies?(">= #{requested_package_version}")
        notifying_block do
          execute 'chef-uninstall' do
            command 'wmic product where "name like \'Chef Client%% %%\'" call uninstall /nointeractive'
            notifies :install, "windows_package[#{new_resource.package_name}]", :immediately
          end

          ruby_block 'Abort Due To Chef Upgrade' do
            block { throw :end_client_run_early_due_to_chef_upgrade }
            action :nothing
          end
          windows_package new_resource.package_name do
            action :nothing
            installer_type :msi
            version new_resource.package_version
            source new_resource.remote_source
            checksum new_resource.package_checksum
            timeout new_resource.timeout
            notifies :run, 'ruby_block[Abort Due To Chef Upgrade]', :immediately
          end
        end
      end
    end
  end
end

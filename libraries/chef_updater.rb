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
    # A custom resource for upgrading the Chef Client.
    # @todo Build a custom resource for managing Omnibus packages.
    # @since 1.0.0
    class ChefUpdater < Chef::Resource
      include Poise(fused: true)
      provides(:chef_updater)

      attribute(:package_name, kind_of: String, name_attribute: true)
      attribute(:package_checksum, kind_of: String)
      attribute(:package_source, kind_of: String)
      attribute(:package_version, kind_of: String)
      attribute(:base_url, kind_of: String)
      attribute(:timeout, kind_of: [String, Integer], default: 900)
      attribute(:package_options, kind_of: String)

      def remote_source
        return package_source if package_source
        ::URI.join(base_url, fancy_basename).to_s
      end

      def fancy_basename
        delimiter = platform_family?('debian') ? '_' : '.'
        [fancy_package_name, fancy_extension].join(delimiter)
      end

      def fancy_package_name
        delimiter = platform_family?('debian') ? '_' : '-'
        [package_name, package_version].join(delimiter)
      end

      def fancy_extension
        arch = node['kernel']['machine']
        if platform_family?('rhel')
          identifier = "el#{node['platform_version'].to_i}"
          "#{identifier}.#{arch}.rpm"
        elsif platform_family?('debian')
          arch = 'amd64' if arch == 'x86_64'
          "#{arch}.deb"
        elsif platform_family?('solaris2')
          "sparc#{node['platform_version']}.solaris"
        elsif platform_family?('aix')
          "#{arch}.bff"
        end
      end

      action(:run) do
        return if new_resource.package_version.split('-') == Chef::VERSION

        notifying_block do
          # HACK: AIX package provider does not support installing from remote.
          location = remote_file new_resource.fancy_basename do
            path ::File.join(Chef::Config[:file_cache_path], new_resource.fancy_basename)
            source new_resource.remote_source
            checksum new_resource.package_checksum if new_resource.package_checksum
          end

          package new_resource.package_name do
            source location.path
            version new_resource.package_version
            provider Chef::Provider::Package::Dpkg if platform?('ubuntu')
            if platform?('solaris2')
              provider Chef::Provider::Package::Solaris
              # TODO: https://github.com/chef/chef/pull/4101
              action :install
            else
              action :upgrade
            end
            timeout new_resource.timeout
            options new_resource.package_options if new_resource.package_options
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

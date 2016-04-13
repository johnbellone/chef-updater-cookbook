#
# Cookbook: chef-updater
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'
require 'uri'

module ChefUpdaterCookbook
  module Resource
    # A custom resource for upgrading the Chef Client.
    # @todo Build a custom resource for managing Omnibus packages.
    # @provides chef_updater
    # @action run
    # @since 1.0
    class ChefUpdater < Chef::Resource
      include Poise(fused: true)
      provides(:chef_updater)

      # @!attribute package_name
      # @return [String]
      attribute(:package_name, kind_of: String, name_attribute: true)
      # @!attribute package_checksum
      # @return [String]
      attribute(:package_checksum, kind_of: String)
      # @!attribute package_source
      # @return [String]
      attribute(:package_source, kind_of: String)
      # @!attribute package_options
      # @return [String]
      attribute(:package_options, kind_of: String)
      # @!attribute package_version
      # @return [String]
      attribute(:package_version, kind_of: String)
      # @!attribute base_url
      # @return [String]
      attribute(:base_url, kind_of: String)
      # @!attribute timeout
      # @return [Integer]
      attribute(:timeout, kind_of: [String, Integer], default: 900)

      def remote_source
        return package_source if package_source
        ::URI.join(base_url, fancy_basename).to_s
      end

      def fancy_basename
        delimiter = case node['platform_family']
                    when 'windows' then '-'
                    when 'debian' then '_'
                    else '.'
                    end
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
          "#{arch}.solaris"
        elsif platform_family?('aix')
          "#{arch}.bff"
        elsif platform_family?('windows')
          arch = 'x64' if arch == 'x86_64'
          "#{arch}.msi"
        end
      end

      action(:run) do
        requested_package_version = new_resource.package_version.split('-').first
        return if chef_version.satisfies?(">= #{requested_package_version}")

        notifying_block do
          location = remote_file new_resource.fancy_basename do
            path ::File.join(Chef::Config[:file_cache_path], new_resource.fancy_basename)
            source new_resource.remote_source
            checksum new_resource.package_checksum if new_resource.package_checksum
          end

          package new_resource.package_name do
            source location.path
            version new_resource.package_version
            provider Chef::Provider::Package::Dpkg if platform?('ubuntu')
            provider Chef::Provider::Package::Solaris if platform?('solaris2')
            action :upgrade
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

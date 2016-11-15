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
    # A `chef_updater` resource which manages the update of the node's
    # Chef Client.
    # @provides chef_updater
    # @action run
    # @since 1.0
    class ChefUpdater < Chef::Resource
      include Poise
      provides(:chef_updater)
      actions(:run)
      default_action(:run)

      # @!attribute package_name
      # @return [String]
      attribute(:package_name, kind_of: String, name_attribute: true)
      # @!attribute package_checksum
      # @return [String]
      attribute(:package_checksum, kind_of: String)
      # @!attribute package_source
      # @return [String]
      attribute(:package_source, kind_of: String)
      # @!attribute package_version
      # @return [String]
      attribute(:package_version, kind_of: String)
      # @!attribute base_url
      # @return [String]
      attribute(:base_url, kind_of: String)
      # @!attribute timeout
      # @return [Integer]
      attribute(:timeout, kind_of: [String, Integer], default: 900)
      # @!attribute use_ips_package
      # @return [Boolean]
      attribute(:use_ips_package, kind_of: [TrueClass, FalseClass], default: false)

      # @return [String]
      def remote_source
        return package_source if package_source
        ::URI.join(base_url, fancy_path, fancy_basename).to_s
      end

      # @api private
      def fancy_basename
        delimiter = case node['platform_family']
                    when 'windows' then '-'
                    when 'debian' then '_'
                    else '.'
                    end
        [fancy_package_name, fancy_extension].join(delimiter)
      end

      def fancy_path
        major   = package_version.split('.')[0].to_i
        minor   = package_version.split('.')[1].to_i
        version = package_version.split('-')[0]
        path    = if major >= 12 && minor >= 14 || major >= 13
                    %W[ files stable chef #{version} #{node['platform']} #{node['platform_version']} ]
                  else
                    %W[ stable #{node['platform']} #{node['platform_version']} ]
                  end
        path.join('/') << '/'
      end

      # @api private
      def fancy_package_name
        delimiter = platform_family?('debian') ? '_' : '-'
        [package_name, package_version].join(delimiter)
      end

      # @api private
      def fancy_extension
        arch = node['kernel']['machine']
        if platform_family?('rhel')
          identifier = "el#{node['platform_version'].to_i}"
          "#{identifier}.#{arch}.rpm"
        elsif platform_family?('debian')
          arch = 'amd64' if arch == 'x86_64'
          "#{arch}.deb"
        elsif platform_family?('solaris2')
          arch = 'sparc' unless arch == 'i386'
          if use_ips_package
            "#{arch}.p5p"
          else
            "#{arch}.solaris"
          end
        elsif platform_family?('aix')
          "#{arch}.bff"
        elsif platform_family?('windows')
          arch = 'x64' if arch == 'x86_64'
          "#{arch}.msi"
        end
      end
    end
  end

  module Provider
    # A `chef_updater` custom provider for managing a node's Chef
    # Client installation using the package provider.
    # @provides chef_updater
    # @action run
    # @since 1.2
    class ChefUpdater < Chef::Provider
      include Poise
      provides(:chef_updater)

      def action_run
        requested_package_version = new_resource.package_version.split('-').first
        return if chef_version.satisfies?(">= #{requested_package_version}")
        notifying_block do
          location = remote_file new_resource.fancy_basename do
            path ::File.join(Chef::Config[:file_cache_path], new_resource.fancy_basename)
            source new_resource.remote_source
            checksum new_resource.package_checksum
          end

          ruby_block 'Abort Due To Chef Upgrade' do
            block { throw :end_client_run_early_due_to_chef_upgrade }
            action :nothing
          end

          if platform?('solaris2') && new_resource.use_ips_package
            # Remove it from the old packaging system if it's there
            # Otherwise, you end up with both
            # The solaris_package resource does not remove packages properly.
            # https://github.com/chef/chef/blob/master/lib/chef/provider/package/solaris.rb#L59
            # it uses pkginfo -d which tells you about the package *in a source*
            # which is not the package *installed on the system*
            # load_current_resource is called when you attempt to use action :remove
            # Ergo, we do it the evil way
            # The "yes" is necessary because pkgrm wants to be interactive
            # and we haven't set up the "admin file" to make it accept -n for chef.
            bash 'uninstall old chef' do
              code 'yes | pkgrm chef'
              only_if 'pkginfo -l chef'
            end
          end

          package new_resource.package_name do
            action :upgrade
            provider Chef::Provider::Package::Dpkg if platform?('ubuntu')
            provider Chef::Provider::Package::Ips if platform?('solaris2') && new_resource.use_ips_package
            provider Chef::Provider::Package::Solaris if platform?('solaris2') && !new_resource.use_ips_package
            source location.path
            version new_resource.package_version
            timeout new_resource.timeout
            notifies :run, 'ruby_block[Abort Due To Chef Upgrade]', :immediately
          end
        end
      end
    end
  end
end

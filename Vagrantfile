%w(vagrant-berkshelf vagrant-cachier vagrant-omnibus).each do |name|
  fail "This project requires the '#{name}' Vagrant plugin!" unless Vagrant.has_plugin?(name)
end
Vagrant.configure('2') do |config|
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest
  config.cache.scope = :box

  config.ssh.forward_agent = true
  config.vm.box = ENV.fetch('VAGRANT_VM_BOX', 'opscode-centos-6.6')
  config.vm.box_url = ENV.fetch('VAGRANT_VM_BOX_URL', 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box')

  # Define an instance which uses this cookbook to create a Sandbox
  # environment for developing Chef infrastructure.
  config.vm.define :instance, primary: true do |guest|
    guest.vm.provision :chef_zero do |chef|
      chef.nodes_path = File.expand_path('../.vagrant/chef/nodes', __FILE__)
      chef.run_list = %w(chef-updater::default)
    end
  end
end

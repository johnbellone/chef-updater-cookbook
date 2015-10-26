require 'spec_helper'

describe_recipe 'chef-updater::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'with all default attributes' do
    it { expect(chef_run).to run_chef_updater('chef').with(package_version: '12.5.1-1') }
    it 'converges successfully' do
      chef_run
    end
  end

  context "with node['chef-updater']['package_version'] = '13.33-7'" do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['chef-updater']['package_version'] = '13.33-7'
      end.converge(described_recipe)
    end

    it { expect(chef_run).to create_chef_updater('chef').with(package_version: '13.33-7') }
    it 'converges successfully' do
      chef_run
    end
  end
end

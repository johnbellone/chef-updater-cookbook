require 'spec_helper'

describe 'chef-updater::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge('chef-updater::default') }

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
      end.converge('chef-updater::default')
    end

    it { expect(chef_run).to run_chef_updater('chef').with(package_version: '13.33-7') }
    it 'converges successfully' do
      chef_run
    end
  end
end

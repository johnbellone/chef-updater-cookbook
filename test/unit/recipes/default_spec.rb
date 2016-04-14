require 'spec_helper'

describe 'chef-updater::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  context 'with default node attributes' do
    it { expect(chef_run).to run_chef_updater('chef').with(package_version: '12.9.38-1') }
  end

  context "with node['chef-updater']['package_version'] = '13.33-7'" do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node, _|
        node.set['chef-updater']['package_version'] = '13.33-7'
      end.converge(described_recipe)
    end

    it { expect(chef_run).to run_chef_updater('chef').with(package_version: '13.33-7') }
  end
end

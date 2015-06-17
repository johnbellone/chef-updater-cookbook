require 'spec_helper'

describe_recipe 'chef-updater::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w{chef_updater}).converge(described_recipe) }

  context 'with default attributes' do
    it { expect(chef_run).to upgrade_package('chef') }
    it 'converges successfully' do
      chef_run
    end
  end
end

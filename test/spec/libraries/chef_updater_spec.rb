require 'spec_helper'
require 'poise_boiler/spec_helper'
require_relative '../../../libraries/chef_updater'

describe ChefUpdaterCookbook::Resource::ChefUpdater do
  step_into(:chef_updater)
end

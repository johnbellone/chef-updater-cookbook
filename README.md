# chef-updater cookbook
[![Build Status](https://img.shields.io/travis/johnbellone/chef-updater-cookbook.svg)](https://travis-ci.org/johnbellone/chef-updater-cookbook)
[![Code Quality](https://img.shields.io/codeclimate/github/johnbellone/chef-updater-cookbook.svg)](https://codeclimate.com/github/johnbellone/chef-updater-cookbook)
[![Test Coverage](https://codeclimate.com/github/johnbellone/chef-updater-cookbook/badges/coverage.svg)](https://codeclimate.com/github/johnbellone/chef-updater-cookbook/coverage)
[![Cookbook Version](https://img.shields.io/cookbook/v/chef-updater.svg)](https://supermarket.chef.io/cookbooks/chef-updater)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

[Application cookbook][0] which provides a simple recipe for updating
the Chef Client package on an instance.

This cookbook supports updating a minimum Chef version of _12.1.0 and
above_. The inspiration for this cookbook comes from the
[Omnibus Updater cookbook][1] which specifically targets the Omnitruck
API for obtaining Chef client artifacts. Unfortunately those of us in
the enterprise likely already have our own mechanisms for distributing
packages, and most of the time they integrate very well with the
operating system's package manager.

## Platforms
This cookbook is tested and used **in production** on the following
platforms:

- RHEL 5/6/7
- CentOS 5/6/7
- Ubuntu 12.04/14.04
- Windows 2008r2/2012r2
- AIX 7.1
- Solaris 11.2

## Basic Usage
Because of how this cookbook short-circuits the Chef convergence it
cannot be run at the compile phase of the run. It should be included
as early as possible in a node's expanded run-list in order to stop a
near-immediately when the client is upgraded.

## Resource/Provider
The default recipe passes in some tuning attributes to the
resource/provider. These attributes should only be tweaked if you
understand what you're doing. It is important to note that by default
the _package_source_ is nil. This means that the system package
provider will attempt to grab it from a potential package repository
(if configured).

Additionally, the _package_version_ should be the semantic version of the
Chef Client that you would like the node to be upgraded to. In the background
a helper transforms this into the version necessary for the platform that
the provider is operating on (e.g. 12.4.0-1.el5).

| Property | Type | Description | Default |
| -------- | ---- | ----------- | ------- |
| package_name | String | Name of package to be upgraded. | 'chef' |
| package_version | String | Version of the package to be upgraded. | '12.9.38' |
| package_source | [String, NilClass] | Remote URL of where package resides. | nil |

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern/#theapplicationcookbook
[1]: https://github.com/hw-cookbooks/omnibus_updater

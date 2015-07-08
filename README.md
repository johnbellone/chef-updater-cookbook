# chef-updater-cookbook
[Application cookbook][0] which provides a simple recipe for updating
the Chef Client package on an instance.

This cookbook supports updating a minimum Chef version of _12.1.0 and
above_. The inspiration for this cookbook comes from the
[Omnibus Updater cookbook][1] which specifically targets the Omnitruck
API for obtaining Chef client artifacts. Unfortunately those of us in
the enterprise likely already have our own mechanisms for distributing
packages, and most of the time they integrate very well with the
operating system's package manager.

## Usage
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
| package_version | String | Version of the package to be upgraded. | '12.4.0' |
| package_source | [String, NilClass] | Remote URL of where package resides. | nil |

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern/#theapplicationcookbook
[1]: https://github.com/hw-cookbooks/omnibus_updater

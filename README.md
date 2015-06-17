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

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern/#theapplicationcookbook
[1]: https://github.com/hw-cookbooks/omnibus_updater

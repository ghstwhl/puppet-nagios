puppet-nagios
=============

Vagrant environment and puppet modules for demo of Puppet Nagios management.
Known to work with Vagrant 1.6.5 and VirtualBox.

This environment is managed using a combination of modules from Puppet Forge
and original Puppet modules.  The key feature is the vo_nagios module, which
does the following:

- Installs Nagios on a Nagios server
- Installs NRPE and associated plug-ins on target servers
- Target servers export host and service resources
- Nagios servers collect resources and build a dynamic Nagios config

Usage:
------

There's a couple of things you need to do to get bootstrapped

Provision the puppet server:
----------------------------

From within the puppet-nagios directory:

    vagrant up puppet1

Now log in to the server with:

    vagrant ssh puppet1

and run

    sudo puppet agent -t

This will complete the provisioning process.  Now you need to reset the admin
password for foreman so you can log in:

    sudo /usr/sbin/foreman-rake permissions:reset

Note the password that it gives you.  Log into the foreman interface at
[This Link][Foreman URL], set the admin password to something sane, go to
"Settings" under "Administer", select the "Auth" tab, and set the value for "restrict_registered_puppetmasters" to "False".  Now reports will show up in
the foreman dashboard.

The rest of the demo functionality (i.e. Nagios) will work fine with or without
Foreman.

Now you can

Provision the rest of the servers:
----------------------------------

with a single

    vagrant up

from the puppet-nagios directory, and have a cup of tea!
It will take a little while!

This will create a nagios server, two web servers, two mysql servers, and an
haproxy server, on the same subnet as your puppet master.

The vo_nagios module in the puppet code will automatically generate nagios
config to monitor the hosts and services as they check in to puppetdb.

To remove a host, shut it down (or disable the puppet agent), and execute:

    sudo puppet node deactivate node-name

where "node-name" is the fqdn of the host (e.g. web1.dev.vagrant.victorops.net).

On the nagios server's next puppet run that host will disappear from the config.

Magic!

The Nagios Interface is at [This Link][Nagios URL]

u: nagiosadmin p: nagiosadmin

Please note the non-sane refresh rate setting in cgi.cfg and the short
check_interval for dev hosts and services.  Adjust these before attempting to
use this code in a production environment.

[Foreman URL]: https://localhost:8442
[Nagios URL]: http://localhost:8083/nagios3/

How to Contribute:
------------------

The main focus of this project is the vo_nagios module, with the hopes that it
can be generalized to the extent that it is suitable for publication on Puppet
Forge.  Work to this end could include:

- Introducing support for additional Linux distributions
- Parameterizing the class
- Allowing selection of which dynamic config files will be built
- Alternative methods for sorting hosts into hostgroups
- Unit tests
- ???

Pull requests will be gladly considered.  Or fork the software for your own
purposes!

License:
--------

   Copyright 2014 VictorOps, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

Included Puppet modules from the Puppet Forge are here redistributed under the
terms of their respective licenses (mostly Apache 2.0 and GNU GPL 2.0).



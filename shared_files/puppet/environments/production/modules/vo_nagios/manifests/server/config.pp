# == Class: vo_nagios::server::config

class vo_nagios::server::config {

  $cfg_tmpdir = hiera('nagios_config_tmpdir')
  $cfg_rundir = hiera('nagios_config_rundir')

  File{
    require =>  Package['nagios3'],
    notify  =>  Service['nagios3'],
  }

  ####
  # Daemon configuration

  # htpasswd.users: user authentication for Nagios
  # u: nagiosadmin, p: nagiosadmin

  $nagiosadmin_password = hiera('nagiosadmin_password')

  file {'/etc/nagios3/htpasswd.users':
    owner   =>  'www-data',
    group   =>  'www-data',
    mode    =>  '0640',
    content =>  template('vo_nagios/nagios/htpasswd.users.erb'),
    notify  =>  undef,
  }

  file {'/etc/nagios3/cgi.cfg':
    owner   =>  'nagios',
    group   =>  'nagios',
    mode    =>  '0644',
    source  =>  'puppet:///modules/vo_nagios/etc/nagios3/cgi.cfg',
  }

  file {'/etc/nagios3/commands.cfg':
    owner   =>  'nagios',
    group   =>  'nagios',
    mode    =>  '0644',
    source  =>  'puppet:///modules/vo_nagios/etc/nagios3/commands.cfg',
  }

  file {'/etc/nagios3/nagios.cfg':
    owner   =>  'nagios',
    group   =>  'nagios',
    mode    =>  '0644',
    source  =>  'puppet:///modules/vo_nagios/etc/nagios3/nagios.cfg',
  }

  file {'/etc/nagios3/resource.cfg':
    owner   =>  'nagios',
    group   =>  'nagios',
    mode    =>  '0644',
    source  =>  'puppet:///modules/vo_nagios/etc/nagios3/resource.cfg',
  }

  ###
  # Monitoring configuration

  # /etc/nagios3/conf.d directory contains general-purpose resources
  file {'/etc/nagios3/conf.d':
    owner   =>  'nagios',
    group   =>  'nagios',
    mode    =>  '0755',
    recurse =>  'inf',
    purge   =>  true,
    source  =>  'puppet:///modules/vo_nagios/etc/nagios3/conf.d',
  }

  # Temp directory for building configs
  file {'/etc/nagios3/tmp':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0755',
  }

  # Build the configs from hiera and exported resources
  # class{ 'vo_nagios::server::config::config_prep': } ->
  class{ 'vo_nagios::server::config::hostgroup': } ->
  class{ 'vo_nagios::server::config::host': } ->
  class{ 'vo_nagios::server::config::servicegroup': } ->
  class{ 'vo_nagios::server::config::service': } ->
  class{ 'vo_nagios::server::config::command': } ->
  class{ 'vo_nagios::server::config::contact': } ->
  class{ 'vo_nagios::server::config::contactgroup': } ->
  class{ 'vo_nagios::server::config::config_install': }

}

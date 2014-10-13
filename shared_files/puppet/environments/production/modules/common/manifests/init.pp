# == Class: common
#
# This Class sets some defaults, calls some common resources, and
# calls additional classes as needed per server type, which is determined
# in site.pp
#
# Puppetlabs would have you do this with "roles" and "profiles" instead
# We do call profiles below, but not for all server types
#
# === Parameters
#
# No parameters.
#
# === Authors
#
# Michael Merideth <mike@victorops.com>
#
# === Copyright
#
# Copyright 2014 VictorOps, Inc., unless otherwise noted.
#
class common {

  # Import top-scope variables so they're available to templates
  $vo_st_nagios_server   = $::vo_st_nagios_server
  $vo_st_puppet_server   = $::vo_st_puppet_server
  $vo_st_database_server = $::vo_st_database_server
  $vo_st_web_server      = $::vo_st_web_server
  $vo_st_haproxy_server  = $::vo_st_haproxy_server
  $vo_location           = $::vo_location
  $vo_env                = $::vo_env

  # We run our servers in UTC, and we love it!
  file { '/etc/timezone':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/common/etc/timezone',
  }

  exec { 'tzset':
    command     => '/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata',
    subscribe   => File['/etc/timezone'],
    refreshonly => true,
  }

  # Custom colored prompts depending on ::vo_env
  file { '/etc/bash.bashrc':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('common/etc/bash.bashrc.erb'),
  }

  # Packages to remove everywhere
  package { 'apparmor':            ensure => purged, }

  # Packages to install everywhere
  package { 'vim':                 ensure => latest, }
  package { 'tree':                ensure => latest, }

  # Call external classes

  if $vo_st_nagios_server {
    if !$::vagrant_apply_bootstrap and !$::vagrant_agent_bootstrap {
			include vo_nagios::server
		}
    class { 'puppet':
			runinterval	=> '300',
			splaylimit	=> '300',
    }
  }

  if $vo_st_puppet_server {
    include ::profile::vo_puppetmaster
  }

  if $vo_st_database_server {
    include ::profile::vo_dbserver
    class { 'puppet':
			runinterval	=> '600',
			splaylimit	=> '600',
    }
  }

  if $vo_st_web_server {
    include ::profile::vo_webserver
    class { 'puppet':
			runinterval	=> '600',
			splaylimit	=> '600',
    }
  }

  if $vo_st_haproxy_server {
    include ::profile::vo_haproxy
    class { 'puppet':
			runinterval	=> '600',
			splaylimit	=> '600',
    }
  }

  # Classes for every host
  # vo_nagios uses exported resources, so don't call it during puppet-apply bootstrap
  if !$::vagrant_apply_bootstrap {
    include vo_nagios::target

		file { '/etc/sudoers.d/10_nagios_puppet_agent':
			ensure 	=> present,
			owner		=> 'root',
			group		=> 'root',
			mode		=> '0440',
			content	=> inline_template("nagios ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/check_file_age\n"),
		}

		@@nagios_service { "${::hostname}.${::vo_env}.${::vo_location}-puppet_agent":
			check_command       => 'check_nrpe_1arg!check_puppet_agent',
			use                 => "${::vo_env}-service",
			display_name        => 'Puppet Agent Status',
			host_name           => "${::fqdn}",
			servicegroups       => 'system-services',
			service_description => "${::hostname}.${::vo_env}.${::vo_location}-puppet_agent",
			tag                 => "${::vo_env}-service",
		}

		file { '/etc/nagios/nrpe.d/check_puppet_agent.cfg':
			owner   => 'nagios',
			group   => 'nagios',
			mode    => '0644',
			content => inline_template("command[check_puppet_agent]=/usr/bin/sudo /usr/lib/nagios/plugins/check_file_age /var/lib/puppet/state/last_run_summary.yaml -w 2700 -c 7200\n"),
			require	=> Package['nagios-nrpe-server'],
			notify  => Service['nagios-nrpe-server'],
		}
  }
}

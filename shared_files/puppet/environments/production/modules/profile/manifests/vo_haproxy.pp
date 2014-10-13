# == Class: profile::vo_haproxy
#
# Full description of class vo_haproxy here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { vo_haproxy:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Michael Merideth <mike@victorops.com>
#
# === Copyright
#
# Copyright 2014 VictorOps, Inc., unless otherwise noted.
#
class profile::vo_haproxy {

  class { 'haproxy':
   global_options   => {
     'log'     => "${::ipaddress_eth1} local0",
     'chroot'  => '/var/lib/haproxy',
     'pidfile' => '/var/run/haproxy.pid',
     'maxconn' => '4000',
     'user'    => 'haproxy',
     'group'   => 'haproxy',
     'daemon'  => '',
     'stats'   => 'socket /var/lib/haproxy/stats'
   },
   defaults_options => {
     'log'     => 'global',
     'stats'   => 'enable',
     'option'  => 'redispatch',
     'retries' => '3',
     'timeout' => [
       'http-request 10s',
       'queue 1m',
       'connect 10s',
       'client 1m',
       'server 1m',
       'check 10s'
     ],
     'maxconn' => '8000'
   },
  }

  $webapp_listening_service = hiera('webapp_listening_service')

  haproxy::listen { $webapp_listening_service:
    collect_exported => true,
    ipaddress        => $::ipaddress_eth1,
    ports            => '80',
    mode             => 'http',
    options          => {
      'option'  => [
        'tcplog',
      ],
    }
  }

  # localhost is 127.0.1.1 on a vagrant box
  haproxy::listen { 'admin':
    ipaddress   => '0.0.0.0',
    ports       => '9000',
    mode        => 'http',
    options     => {
      'stats' => [
        'enable',
        'uri /',
        'refresh 2',
      ]
    }
  }

  Haproxy::Balancermember <<| listening_service == hiera('webapp_listening_service') |>>

  package { 'nagios-plugins-contrib':
    ensure  => installed,
    require => Class['haproxy'],
  }

  if !$::vagrant_apply_bootstrap {
    @@nagios_service { "${::hostname}.${::vo_env}.${::vo_location}-haproxy":
      check_command       => 'check_nrpe_1arg!check_haproxy',
      use                 => "${::vo_env}-service",
      display_name        => 'Haproxy Status',
      host_name           => "${::fqdn}",
      servicegroups       => 'application-services',
      service_description => "${::hostname}.${::vo_env}.${::vo_location}-haproxy",
      tag                 => "${::vo_env}-service",
    }

    file { '/etc/nagios/nrpe.d/check_haproxy.cfg':
      owner   => 'nagios',
      group   => 'nagios',
      mode    => '0644',
      content => inline_template("command[check_haproxy]=usr/lib/nagios/plugins/check_haproxy -u \'http://127.0.0.1:9000/;csv;norefresh\'\n"),
      require => Package['nagios-plugins-contrib','nagios-nrpe-server'],
      notify  => Service['nagios-nrpe-server'],
    }
  }

}

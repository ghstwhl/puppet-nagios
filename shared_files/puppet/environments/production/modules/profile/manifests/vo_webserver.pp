# == Class: profile::vo_webserver
#
# Full description of class vo_webserver here.
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
#  class { vo_webserver:
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
class profile::vo_webserver {

  class{ '::apache':
    purge_configs =>  true,
    mpm_module    =>  'prefork',
  }

  class{ '::apache::mod::php': }
  class{ '::apache::mod::ssl': }
  ::apache::mod{ 'authn_core': }

  @@haproxy::balancermember { "${::hostname}":
    listening_service => hiera('webapp_listening_service'),
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress_eth1,
    ports             => '80',
    options           => 'check',
  }

  @@nagios_service { "${::hostname}.${::vo_env}.${::vo_location}-http":
    check_command       => 'check_http',
    use                 => "${::vo_env}-service",
    display_name        => 'http port 80',
    host_name           => "${::fqdn}",
    servicegroups       => 'application-services',
    service_description => "${::hostname}.${::vo_env}.${::vo_location}-http",
    tag                 => "${::vo_env}-service",
  }

  if !$::vagrant_apply_bootstrap {
    @@nagios_service { "${::hostname}.${::vo_env}.${::vo_location}-apache2":
      check_command       => 'check_nrpe_1arg!check_apache2',
      use                 => "${::vo_env}-service",
      display_name        => 'apache2 process',
      host_name           => "${::fqdn}",
      servicegroups       => 'application-services',
      service_description => "${::hostname}.${::vo_env}.${::vo_location}-apache2",
      tag                 => "${::vo_env}-service",
    }

    file { '/etc/nagios/nrpe.d/check_apache2.cfg':
      owner   => 'nagios',
      group   => 'nagios',
      mode    => '0644',
      content => inline_template("command[check_apache2]=/usr/lib/nagios/plugins/check_procs -C apache2\n"),
      require	=> Package['nagios-nrpe-server'],
      notify  => Service['nagios-nrpe-server'],
    }
  }

}

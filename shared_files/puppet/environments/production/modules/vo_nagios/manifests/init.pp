# == Class: vo_nagios
#
# Full description of class vo_nagios here.
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
#  class { vo_nagios:
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
class vo_nagios {

  $vo_location = $::vo_location
  $vo_env      = $::vo_env

  # Plugins go everywhere
  package { 'nagios-plugins':           ensure => installed }
  package { 'nagios-plugins-standard':  ensure => installed }
  package { 'nagios-plugins-basic':     ensure => installed }

  file { '/usr/lib/nagios/plugins/local':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package['nagios-plugins'],
  }
}

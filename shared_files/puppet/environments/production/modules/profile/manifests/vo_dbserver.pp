# Class profile::vo_dbserver
# Apt resource definitions shamelessly stolen from arioch/puppet-percona

class profile::vo_dbserver {

  $mysql_rootpw     = hiera('mysql::server::root_password')
  $nrpe_mysql_user  = hiera('nrpe_mysql_user')

  include apt

  # Here we install and configure database servers
  class { 'mysql::server': }
  class { 'mysql::bindings':
    php_enable => true,
  }

  apt::key { 'CD2EFD2A':
    ensure => present,
    notify => Exec['profile::vo_dbserver::apt-get update'],
  }

  apt::source { 'percona':
    ensure      => present,
    include_src => true,
    location    => 'http://repo.percona.com/apt',
    release     => $::lsbdistcodename,
    repos       => 'main',
    notify      => Exec['profile::vo_dbserver::apt-get update'],
    require     => Apt::Key['CD2EFD2A'],
  }

  exec { 'profile::vo_dbserver::apt-get update':
    command     => 'apt-get update',
    path        => '/usr/bin',
    refreshonly => true,
  }

  package { 'percona-nagios-plugins':
    ensure  => installed,
    require => Apt::Source['percona'],
  }

  if !$::vagrant_apply_bootstrap {
    @@nagios_service { "${::hostname}.${::vo_env}.${::vo_location}-mysql_pidfile":
      check_command       => 'check_nrpe_1arg!check_mysql_pidfile',
      use                 => "${::vo_env}-service",
      display_name        => 'MySQL PIDfiles',
      host_name           => "${::fqdn}",
      servicegroups       => 'application-services',
      service_description => "${::hostname}.${::vo_env}.${::vo_location}-mysql_pidfile",
      tag                 => "${::vo_env}-service",
    }

    file { '/etc/nagios/nrpe.d/check_mysql_pidfile.cfg':
      owner   => 'nagios',
      group   => 'nagios',
      mode    => '0644',
      content => inline_template("command[check_mysql_pidfile]=/usr/lib64/nagios/plugins/pmp-check-mysql-pidfile -l <%= @nrpe_mysql_user %> -p <%= @mysql_rootpw %>\n"),
      require => Package['percona-nagios-plugins','nagios-nrpe-server'],
      notify  => Service['nagios-nrpe-server'],
    }
  }

}

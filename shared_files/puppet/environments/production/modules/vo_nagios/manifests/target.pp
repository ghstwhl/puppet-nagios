# == Class: vo_nagios::target

# Here we set up host resources for everyone

class vo_nagios::target {

  include vo_nagios
  require vo_nagios::target::hostgroups

  $nag_alias          = regsubst($::fqdn,'\.victorops\.net$','')
  $cfg_tmpdir         = hiera('nagios_config_tmpdir')
  $nrpe_allowed_hosts = hiera('nagios_serverip')

  @@nagios_host { $::fqdn:
    alias       => $nag_alias,
    address     => $::ipaddress_eth1,  # particular to Vagrant, we use the eth1 IP
    use         => "${::vo_env}-host",
    hostgroups  => $::vo_nagios::target::hostgroups::my_hostgroups,
    tag         => "${::vo_env}-host",
    target      => "${cfg_tmpdir}/hosts.cfg",
    owner       => 'nagios',
    group       => 'nagios',
    mode        => '0644',
  }

  package { 'nagios-nrpe-server': ensure => installed } ->

  file { '/etc/nagios/nrpe.cfg':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('vo_nagios/nrpe/nrpe.cfg.erb'),
    notify  => Service['nagios-nrpe-server'],
    require => Package['nagios-nrpe-server'],
  }

  service { 'nagios-nrpe-server':
    ensure  =>  'running',
    enable  =>  true,
    require =>  File['/etc/nagios/nrpe.cfg'],
  }

}

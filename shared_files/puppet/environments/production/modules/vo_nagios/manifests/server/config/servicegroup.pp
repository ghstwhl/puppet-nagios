# == Class: vo_nagios::server::config::servicegroup

class vo_nagios::server::config::servicegroup {

  $cfg_tmpdir         = $::vo_nagios::server::config::cfg_tmpdir
  $servicegroups_file = "${cfg_tmpdir}/servicegroups.cfg"

  Nagios_servicegroup{
    require => Package['nagios3'],
    target  => $servicegroups_file,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0644',
  }

  # Call out all of our nagios servicegroups
  $nag_local_servicegroups = hiera('nag_local_servicegroups')
  nagios_servicegroup { $nag_local_servicegroups:
    ensure  => present,
  }

}

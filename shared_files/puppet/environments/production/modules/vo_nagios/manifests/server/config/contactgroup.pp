# == Class: vo_nagios::server::config::contactgroup

class vo_nagios::server::config::contactgroup {

  $cfg_tmpdir         = $::vo_nagios::server::config::cfg_tmpdir
  $contactgroups_file = "${cfg_tmpdir}/contactgroups.cfg"

  Nagios_contactgroup{
    require => Package['nagios3'],
    target  => $contactgroups_file,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0644',
  }

  # Call out all of our nagios contactgroups
  $nag_local_contactgroups = hiera('nag_local_contactgroups')
  nagios_contactgroup { $nag_local_contactgroups:
    ensure  => present,
  }

}

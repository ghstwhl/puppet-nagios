# == Class: vo_nagios::server::config::hostgroup

class vo_nagios::server::config::hostgroup {

  $cfg_tmpdir       = $::vo_nagios::server::config::cfg_tmpdir
  $hostgroups_file  = "${cfg_tmpdir}/hostgroups.cfg"

  Nagios_hostgroup{
    require => Package['nagios3'],
    target  => $hostgroups_file,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0644',
  }

  # Call out all of our nagios hostgroups
  $nag_local_hostgroups = hiera('nag_local_hostgroups')
  nagios_hostgroup { $nag_local_hostgroups:
    ensure  => present,
  }

  # Purge unmanaged hostgroups
  # Hint: this doesn't work
  resources{ 'nagios_hostgroup':
    purge => true,
  }

}

# == Class: vo_nagios::server::config::config_prep

class vo_nagios::server::config::config_prep {

  $cfg_tmpdir = $::vo_nagios::server::config::cfg_tmpdir

  exec{ "/bin/rm -f ${cfg_tmpdir}/*" : }

}

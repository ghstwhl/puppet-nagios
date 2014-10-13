# == Class: vo_nagios::server::config::command

class vo_nagios::server::config::command {

  $cfg_tmpdir     = $::vo_nagios::server::config::cfg_tmpdir
  $commands_file  = "${cfg_tmpdir}/commands.cfg"

  # Defaults for Nagios resources
  Nagios_command{
    require => Package['nagios3'],
    target  => $commands_file,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0644',
  }

  # Generate config
  case $::vo_env {
    'pr': {
      Nagios_command <<| tag == 'pr-command' |>>
    }
    'stg': {
      Nagios_command <<| tag == 'stg-command' |>>
    }
    'dev': {
      Nagios_command <<| tag == 'dev-command' |>>
    }
    'lab': {
      Nagios_command <<| tag == 'lab-command' |>>
    }
    default: {
      fail("Module ${module_name} is not supported for ${::vo_env}")
    }
  }

  Nagios_command <<| tag == 'generic-command' |>>

}

# == Class: vo_nagios::server::config::service

class vo_nagios::server::config::service {

  $cfg_tmpdir     = $::vo_nagios::server::config::cfg_tmpdir
  $services_file  = "${cfg_tmpdir}/services.cfg"

  # Defaults for Nagios resources
  Nagios_service{
    require => Package['nagios3'],
    target  => $services_file,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0644',
  }

  # Generate config
  case $::vo_env {
    'pr': {
      Nagios_service <<| tag == 'pr-service' |>>
    }
    'stg': {
      Nagios_service <<| tag == 'stg-service' |>>
    }
    'dev': {
      Nagios_service <<| tag == 'dev-service' |>>
    }
    'lab': {
      Nagios_service <<| tag == 'lab-service' |>>
    }
    default: { fail("Module ${module_name} is not supported for ${::vo_env}") }
  }

  Nagios_service <<| tag == 'generic-service' |>>

}

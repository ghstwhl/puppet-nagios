# == Class: vo_nagios::server::config::host

class vo_nagios::server::config::host {

  $hosts_file = "/etc/nagios3/tmp/hosts.cfg"

  # Defaults for Nagios resources
  Nagios_host{
    require => Package['nagios3'],
  }

  case $::vo_env {
    'pr': {
      Nagios_host <<| tag == 'generic-host' |>>
      Nagios_host <<| tag == 'pr-host' |>>
    }
    'stg': {
      Nagios_host <<| tag == 'stg-host' |>>
    }
    'dev': {
      Nagios_host <<| tag == 'dev-host' |>>
    }
    'lab': {
      Nagios_host <<| tag == 'lab-host' |>>
    }
    default: { fail("Module ${module_name} is not supported for ${::vo_env}") }
  }

}

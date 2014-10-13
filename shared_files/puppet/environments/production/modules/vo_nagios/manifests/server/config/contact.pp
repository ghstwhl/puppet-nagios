# == Class: vo_nagios::server::config::contact

class vo_nagios::server::config::contact {

  $cfg_tmpdir     = $::vo_nagios::server::config::cfg_tmpdir
  $contacts_file  = "${cfg_tmpdir}/contacts.cfg"

  # Defaults for Nagios resources
  Nagios_contact{
    require => Package['nagios3'],
    target  => $contacts_file,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0644',
  }

  case $::vo_env {
    'pr': {
      Nagios_contact <<| tag == 'generic-contact' |>>
      Nagios_contact <<| tag == 'pr-contact' |>>
    }
    'stg': {
      Nagios_contact <<| tag == 'generic-contact' |>>
      Nagios_contact <<| tag == 'stg-contact' |>>
    }
    'dev': {
      Nagios_contact <<| tag == 'generic-contact' |>>
      Nagios_contact <<| tag == 'dev-contact' |>>
    }
    'lab': {
      Nagios_contact <<| tag == 'generic-contact' |>>
      Nagios_contact <<| tag == 'lab-contact' |>>
    }
    default: { fail("Module ${module_name} is not supported for ${::vo_env}") }
  }

}

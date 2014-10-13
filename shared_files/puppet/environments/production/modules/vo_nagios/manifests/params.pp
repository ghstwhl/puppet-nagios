# == Class:  vo_nagios::params
class vo_nagios::params {

  $nag_dyn_configfiles = [
    'commands.cfg',
    'contacts.cfg',
    'contactgroups.cfg',
    'hosts.cfg',
    'hostgroups.cfg',
    'services.cfg',
    'servicegroups.cfg',
  ]

}

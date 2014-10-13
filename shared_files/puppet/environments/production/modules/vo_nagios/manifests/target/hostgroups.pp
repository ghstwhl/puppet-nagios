# == Class: vo_nagios::target::hostgroups
# Here we determine host group membership for a node
class vo_nagios::target::hostgroups {

  $base_hostgroup = [ 'all' ]

  $env_hostgroup = "${::vo_env}-servers"
  $loc_hostgroup = "${::vo_location}-servers"

  case $::lsbdistid {
    'Ubuntu': { $lsbdist_hostgroup = 'ubuntu-servers' }
    default : { fail("Module ${module_name} is not supported for ${::lsbdistid}") }
  }

  if $::is_virtual {
    $vhostgroup = "virtual-servers"
  } else {
    $vhostgroup = "physical-servers"
  }

  $nag_gr_nagios_servers    = $::vo_st_nagios_server
  $nag_gr_puppet_servers    = $::vo_st_puppet_server
  $nag_gr_database_servers  = $::vo_st_database_server
  $nag_gr_web_servers       = $::vo_st_web_server
  $nag_gr_haproxy_servers   = $::vo_st_haproxy_server

  $nagios_raw_func_hostgroups    = inline_template( '<%= Hash[scope.to_hash.select{ |k,v| k =~ /nag_gr_/ && v }].keys.join(",") %>' )
  $nagios_us_func_hostgroups     = regsubst($nagios_raw_func_hostgroups,'nag_gr_', '', 'G')
  $nagios_func_hostgroups        = regsubst($nagios_us_func_hostgroups, '_', '-', 'G')

  $my_hostgroups = join([$base_hostgroup,$env_hostgroup,$loc_hostgroup,$lsbdist_hostgroup,$vhostgroup,$nagios_func_hostgroups], ',')
  $hostgroup_array = split($my_hostgroups, ',')

}

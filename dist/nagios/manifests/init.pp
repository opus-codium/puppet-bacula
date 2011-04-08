# Class: nagios
#
# This class installs and configures Nagios
#
# Parameters:
#   $nrpe_server:
#     IP address of the NRPE monitoring server
#
# Actions:
#
# Requires:
#   - The nagios::params class
#
# Sample Usage:
#
class nagios {
  include nagios::params

  $nrpe_server = $nagios::params::nrpe_server
  $nrpe_pid = $nagios::params::nrpe_pid
  $nrpe_user = $nagios::params::nrpe_user
  $nrpe_group = $nagios::params::nrpe_group

  package { [ $nagios::params::nagios_plugin_packages, $nagios::params::nrpe_packages ]:
    ensure => installed,
  }

  file { '/etc/nagios': 
    ensure => present,
    require => Package[$nagios::params::nrpe_packages],
  }

  file { $nagios::params::nrpe_configuration:
    ensure => present,
    owner => nagios,
    group => nagios,
    content => template('nagios/nrpe.cfg.erb'),
    notify => Service[$nagios::params::nrpe_service],
    require => File['/etc/nagios'],
  }

  service { $nagios::params::nrpe_service:
    pattern => 'nrpe',
    ensure => running,
    enable     => true,
    hasrestart => true,
    require => [ File[$nagios::params::nrpe_configuration], Package[$nagios::params::nrpe_packages] ],
  }

  @@nagios_host { $fqdn:
    ensure => present,
    alias => $hostname,
    address => $ipaddress,
    use => 'generic-host',
    target => '/etc/nagios3/conf.d/nagios_host.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_ping_${hostname}":
    use => 'generic-service',
    check_command => 'check_ping!100.0,20%!500.0,60%',
    host_name => "$fqdn",
    service_description => "check_ping_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_ssh_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_ssh', 
    service_description => "check_ssh_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_dns_${hostname}":
	  ensure => absent,
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_dns',
    service_description => "check_dns_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  #@@nagios_service { "check_bacula_${hostname}":
  #  use => 'generic-service',
  #  host_name => "$fqdn",
  #  check_command => 'check_bacula',
  #  service_description => "check_bacula_${hostname}",
  #  target => '/etc/nagios3/conf.d/nagios_service.cfg',
  #  notify => Service[$nagios::params::nagios_service],
  #}

  @@nagios_service { "check_disk_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_nrpe_1arg!check_xvda',
    service_description => "check_disk_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_load_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_nrpe_1arg!check_load',
    service_description => "check_load_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_zombie_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_nrpe_1arg!check_zombie_procs',
    service_description => "check_zombie_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }
  
  @@nagios_service { "check_puppetd_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => $puppetversion ? {
			'0.25.4' => 'check_nrpe!check_proc!1:1 puppetd',
			default => $operatingsystem ? {
				CentOS  => 'check_nrpe!check_proc!1:1 puppetd',
				default => 'check_nrpe!check_proc!1:1 puppet',
			},
		},
    service_description => "check_puppetd_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_munin-node_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_nrpe!check_proc!1:1 munin-node',
    service_description => "check_munin-node_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_collectd_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_nrpe!check_proc!1:1 collectd',
    service_description => "check_collectd_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  @@nagios_service { "check_collectdmon_${hostname}":
    use => 'generic-service',
    host_name => "$fqdn",
    check_command => 'check_nrpe!check_proc!1:1 collectdmon',
    service_description => "check_collectdmon_${hostname}",
    target => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify => Service[$nagios::params::nagios_service],
  }

  file { "/usr/lib/nagios/plugins/check_bacula.pl":
    source => "puppet:///modules/nagios/check_bacula.pl",
    mode => 0755,
    ensure => present,
  }
}
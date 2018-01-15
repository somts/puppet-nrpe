## Class: nrpe::params
##
## Parameters for the nrpe module
##
class nrpe::params {
  validate_re($::osfamily,'(^RedHat|Debian|Ubuntu|Darwin|FreeBSD|Solaris)$',
  "${::osfamily} unsupported")

  # Define where config files are stored based on expected provider.
  $etc = $::osfamily ? {
    'Darwin'  => '/opt/local/etc', # MacPorts
    'FreeBSD' => '/usr/local/etc',
    'Solaris' => '/etc/opt/csw',   # OpenCSW
    default   => '/etc',
  }
  $run = $::osfamily ? {
    'Darwin'  => '/opt/local/var/run', # MacPorts
    default   => '/var/run',
  }
  $normal_etc = $::osfamily ? {
    'Darwin'  => '/private/etc',
    'FreeBSD' => '/usr/local/etc',
    default   => '/etc',
  }

  $ensure             = 'present'
  $service_status     = true
  $service_restart    = true
  $config_file_owner  = 'root'
  $config_file_mode   = '0644'
  $plugin_owner       = 'root'
  $plugin_mode        = '0755'
  $manage_firewall    = $::kernel ? {
    'Linux' => true,
    default => false,
  }
  $firewall_priority  = '200'
  $ntp                = 'localhost'
  $source             = undef
  $content            = undef
  $server             = undef
  $zfs                = false
  $zfs_verbosity      = 1 # anything higher breaks on Linux

  $use_zfs_sudo = $::osfamily ? {
    'RedHat' => true,
    default  => false,
  }

  # nrpe.cfg default settings
  $allowed_hosts      = ['127.0.0.1']
  $command_timeout    = 60
  $connection_timeout = 300
  $debug              = false
  $dont_blame_nrpe    = true
  $include_dir        = $::osfamily ? {
    'Darwin' => "${etc}/nrpe/nrpe.d",
    'Debian' => "${etc}/nagios/nrpe.d",
    'RedHat' => "${etc}/nagios/nrpe.d",
    default  => "${etc}/nrpe.d",
  }
  $log_facility       = 'daemon'
  $nrpe_group         = $::osfamily ? {
    'RedHat' => 'nrpe',
    default  => 'nagios',
  }
  $nrpe_user          = $::osfamily ? {
    'RedHat' => 'nrpe',
    default  => 'nagios',
  }
  $pid_file           = $::osfamily ? {
    'Darwin'  => "${run}/nrpe/nrpe.lock",
    'FreeBSD' => "${run}/nrpe2/nrpe2.pid",
    'RedHat'  => "${run}/nrpe/nrpe.pid",
    default   => "${run}/nrpe.pid",
  }
  $server_port        = 5666

  $service = $::osfamily ? {
    'Darwin'  => 'org.macports.nrpe',
    'Debian'  => 'nagios-nrpe-server',
    'FreeBSD' => 'nrpe2',
    'Solaris' => 'svc:/network/cswnrpe:default',
    default   => 'nrpe',
  }

  $package = $::osfamily ? {
    'Debian'  => 'nagios-nrpe-server',
    'FreeBSD' => 'nrpe-ssl',
    default   => 'nrpe',
  }

  $plugins_packages = $::osfamily ? {
    'FreeBSD' => [
      'nagios-plugins',
      'nagios-snmp-plugins-extras',
      'py27-nagios-check_mongodb',
      'nagios-check_tftp',
      'nagios-check_redis',
      'nagios-pf-plugin',
    ],
    'Debian'  => [
      'nagios-nrpe-plugin',
      'nagios-plugins',
      'nagios-plugins-basic',
      'nagios-plugins-common',
      'nagios-plugins-standard',
      'nagios-plugin-check-multi',
      'nagios-plugins-contrib',
      'nagios-plugins-extra',
      'nagios-plugins-openstack',
      'nagios-snmp-plugins',
    ],
    'RedHat'  => ['nagios-plugins-all','nagios-plugins-nrpe'],
    'Solaris' => ['nagios_plugins'],
    default   => ['nagios-plugins'],
  }

  $configfile = $::osfamily ? {
    'Darwin' => "${etc}/nrpe/nrpe.cfg",
    'Debian' => "${etc}/nagios/nrpe.cfg",
    'RedHat' => "${etc}/nagios/nrpe.cfg",
    default  => "${etc}/nrpe.cfg",
  }

  $config_group = $::osfamily ? {
    /(Darwin|BSD)$/ => 'wheel',
    'Solaris'       => 'bin',
    default         => 'root',
  }

  $pluginsdir = $::osfamily ? {
    'Darwin'  => '/opt/local/libexec/nagios',
    'Debian'  => '/usr/lib/nagios/plugins',
    'FreeBSD' => '/usr/local/libexec/nagios',
    'RedHat'  => $::architecture ? {
      'x86_64' => '/usr/lib64/nagios/plugins',
      default  => '/usr/lib/nagios/plugins',
    },
    'Solaris' => '/opt/csw/libexec/nagios-plugins',
    default   => '/usr/libexec/nagios-plugins',
  }

  $plugin_group = $::osfamily ? {
    'Darwin'  => 'wheel',
    'FreeBSD' => 'wheel',
    'Solaris' => 'bin',
    default   => 'root',
  }
  $sudoers_exe  = $::kernel ? {
    'Darwin' => '/usr/bin/sudo',
    'RedHat' => '/bin/sudo',
    'SunOS'  => '/opt/csw/bin/sudo',
    default  => '/usr/bin/sudo',
  }

  # Conditionally build some plugin and command hashes...
  $global_plugins = {
    check_myfilesize => {
      source => 'puppet:///modules/nrpe/plugins/check_myfilesize.pl',
    },
  }
  $global_commands = {
    check_users          => { command => 'check_users -w 5 -c 10' },
    check_load           => { command => 'check_load -w 15,10,5 -c 30,25,20' },
    check_all_disks      => { command => 'check_disk  -w 20% -c 10% -A' },
    check_zombie_procs   => { command => 'check_procs -w 5 -c 10 -s Z' },
    check_total_procs    => { command => 'check_procs -w 150 -c 200' },
    check_process        => { command => 'check_procs -c 1: -C "$ARG1$"' },
    check_processwitharg => {
      command => 'check_procs -c 1: -C "$ARG1$" -a "$ARG2$"'
    },
    check_port_tcp       => { command => 'check_tcp  -H "$ARG1$" -p "$ARG2$"' },
    check_port_udp       => { command => 'check_udp  -H "$ARG1$" -p "$ARG2$"' },
    check_swap           => { command => 'check_swap -w 50 -c 10' },
    check_mailq          => { command => 'check_mailq -w 1 -c 5' },
    check_load           => { command => 'check_load  -w 15,10,5 -c 30,25,20' },
    check_procs          => {
      command => 'check_procs  -w $ARG1$ -c $ARG2$ -a "$ARG3$"'
    },
    check_file_age       => {
      command => 'check_file_age -w $ARG1$ -c $ARG2$ -f $ARG3$'
    },
    check_url            => {
      command => 'check_http -I "$ARG1$" -p "$ARG2$" -u "$ARG3$" -s "$ARG4$"'
    },
    check_url_auth       => {
      command =>
      'check_http -I "$ARG1$" -p "$ARG2$" -u "$ARG3$" -s "$ARG4$" -a "$ARG5$"'
    },
    check_myfilesize     => {
      command => 'check_myfilesize $ARG1$ $ARG2$ $ARG3$',
    },
  }

  $linux_plugins = {
    'check_open_files' => {
      source => 'puppet:///modules/nrpe/plugins/check_open_files.pl',
    },
  }
  $linux_commands = {
    'check_open_files' => {
      command => 'check_open_files -w 80 -c 90',
    },
  }

  $plugins = $::kernel ? {
    'Linux' => $global_plugins + $linux_plugins,
    default => $global_plugins,
  }
  $commands = $::kernel ? {
    'Linux' => $global_commands + $linux_commands,
    default => $global_commands,
  }
}

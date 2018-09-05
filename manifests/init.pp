## Class nrpe
##
## Manages the nagios remote plugin execution daemon
##
## Parameters:
## *ensure*
##   (Un)installs nrpe entirely
##
## *source*
##   file to use for nrpe.cfg
##
## *content*
##  The content to use for nrpe.cfg
##
## *debug*
##  Turns on nrpe debugging
##
## *ntp*
##  NTP host address to check.
##
## *commands*
##  A hash of commands that may override the defaults from params.
##
## *plugins*
##  A hash of commands that may override the defaults from params.
class nrpe(
  Enum[absent,present] $ensure,
  Hash $commands,
  Hash $plugins,
  String $service,
  Boolean $service_status,
  Boolean $service_restart,
  Stdlib::Absolutepath $config_file,
  String $config_file_owner,
  String $config_file_group,
  String $config_file_mode,
  String $plugin_owner,
  String $plugin_group,
  String $plugin_mode,
  Stdlib::Absolutepath $normal_etc,
  String $package,
  Array $plugins_packages,
  Stdlib::Absolutepath $pluginsdir,
  Stdlib::Absolutepath $sudoers_exe,
  Boolean $manage_checkntp,
  Boolean $manage_checkzfs,
  Boolean $manage_checkznapzend,
  Boolean $manage_firewall,
  Boolean $manage_logfile,
  String $firewall_priority,
  Optional[String] $ntp,
  Boolean $use_zfs_sudo,
  Integer $zfs_verbosity,
  Optional[String] $source,
  Optional[String] $content,
  #
  # nrpe.cfg settings follow...
  #
  String $log_facility,
  Optional[Stdlib::Absolutepath] $log_file,
  Boolean $debug,
  Stdlib::Absolutepath $pid_file,
  Integer $server_port,
  Optional[String] $server_address,
  Optional[String] $listen_queue_size,
  String $nrpe_user,
  String $nrpe_group,
  Array $allowed_hosts,
  Boolean $dont_blame_nrpe,
  Boolean $allow_bash_command_substitution,
  Optional[Stdlib::Absolutepath] $command_prefix,
  Integer $max_commands,
  Integer $command_timeout,
  Integer $connection_timeout,
  Boolean $allow_weak_random_seed,
  Optional[String] $ssl_version,
  Optional[Boolean] $ssl_use_adh,
  Optional[String] $ssl_cipher_list,
  Optional[Stdlib::Absolutepath] $ssl_cacert_file,
  Optional[Stdlib::Absolutepath] $ssl_cert_file,
  Optional[Stdlib::Absolutepath] $ssl_privatekey_file,
  Integer $ssl_client_certs,
  Enum['0x00','0x01','0x02','0x04','0x08','0x10','0x20','-1'] $ssl_logging,
  Optional[String] $nasty_metachars,
  Optional[Stdlib::Absolutepath] $include,
  Stdlib::Absolutepath $include_dir,
) {

  if $ensure == 'present' {
    Class['nrpe::install'] -> Class['nrpe::config'] ~> Class['nrpe::service']
  } else {
    Class['nrpe::service'] -> Class['nrpe::config'] -> Class['nrpe::install']
  }

  contain nrpe::install
  contain nrpe::config
  contain nrpe::service
}

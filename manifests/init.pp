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
  Enum[absent,present] $ensure       = $nrpe::params::ensure,
  Hash $commands                     = $nrpe::params::commands,
  Hash $plugins                      = $nrpe::params::plugins,
  String $service                    = $nrpe::params::service,
  Boolean $service_status            = $nrpe::params::service_status,
  Boolean $service_restart           = $nrpe::params::service_restart,
  Stdlib::Absolutepath $config_file  = $nrpe::params::configfile,
  String $config_file_owner          = $nrpe::params::config_file_owner,
  String $config_file_group          = $nrpe::params::config_group,
  String $config_file_mode           = $nrpe::params::config_file_mode,
  String $plugin_owner               = $nrpe::params::plugin_owner,
  String $plugin_group               = $nrpe::params::plugin_group,
  String $plugin_mode                = $nrpe::params::plugin_mode,
  Stdlib::Absolutepath $normal_etc   = $nrpe::params::normal_etc,
  String $package                    = $nrpe::params::package,
  Array $plugins_packages            = $nrpe::params::plugins_packages,
  Stdlib::Absolutepath $pluginsdir   = $nrpe::params::pluginsdir,
  Stdlib::Absolutepath $sudoers_exe  = $nrpe::params::sudoers_exe,
  Boolean $manage_checkntp           = $nrpe::params::manage_checkntp,
  Boolean $manage_checkzfs           = $nrpe::params::manage_checkzfs,
  Boolean $manage_checkznapzend      = $nrpe::params::manage_checkznapzend,
  Boolean $manage_firewall           = $nrpe::params::manage_firewall,
  Boolean $manage_logfile            = $nrpe::params::manage_logfile,
  String $firewall_priority          = $nrpe::params::firewall_priority,
  Optional[String] $ntp              = $nrpe::params::ntp,
  Boolean $use_zfs_sudo              = $nrpe::params::use_zfs_sudo,
  Integer $zfs_verbosity             = $nrpe::params::zfs_verbosity,
  Optional[String] $source           = $nrpe::params::source,
  Optional[String] $content          = $nrpe::params::content,
  # nrpe.cfg settings follow...
  String $log_facility = $nrpe::params::log_facility,
  Optional[Stdlib::Absolutepath] $log_file = $nrpe::params::log_file,
  Boolean $debug = $nrpe::params::debug,
  Stdlib::Absolutepath $pid_file = $nrpe::params::pid_file,
  Integer $server_port = $nrpe::params::server_port,
  Optional[String] $server_address = $nrpe::params::server_address,
  Optional[String] $listen_queue_size = $nrpe::params::listen_queue_size,
  String $nrpe_user = $nrpe::params::nrpe_user,
  String $nrpe_group = $nrpe::params::nrpe_group,
  Array $allowed_hosts = $nrpe::params::allowed_hosts,
  Boolean $dont_blame_nrpe = $nrpe::params::dont_blame_nrpe,
  Boolean $allow_bash_command_substitution =
  $nrpe::params::allow_bash_command_substitution,
  Optional[Stdlib::Absolutepath] $command_prefix
  = $nrpe::params::command_prefix,
  Integer $max_commands = $nrpe::params::max_commands,
  Integer $command_timeout = $nrpe::params::command_timeout,
  Integer $connection_timeout = $nrpe::params::connection_timeout,
  Boolean $allow_weak_random_seed = $nrpe::params::allow_weak_random_seed,
  Optional[String] $ssl_version = $nrpe::params::ssl_version,
  Optional[Boolean] $ssl_use_adh = $nrpe::params::ssl_use_adh,
  Optional[String] $ssl_cipher_list = $nrpe::params::ssl_cipher_list,
  Optional[Stdlib::Absolutepath] $ssl_cacert_file
  = $nrpe::params::ssl_cacert_file,
  Optional[Stdlib::Absolutepath] $ssl_cert_file = $nrpe::params::ssl_cert_file,
  Optional[Stdlib::Absolutepath] $ssl_privatekey_file
  = $nrpe::params::ssl_privatekey_file,
  Integer $ssl_client_certs = $nrpe::params::ssl_client_certs,
  Enum['0x00','0x01','0x02','0x04','0x08','0x10','0x20','-1'] $ssl_logging
  = $nrpe::params::ssl_logging,
  Optional[String] $nasty_metachars = $nrpe::params::nasty_metachars,
  Optional[Stdlib::Absolutepath] $include = $nrpe::params::include,
  Stdlib::Absolutepath $include_dir = $nrpe::params::include_dir,
) inherits nrpe::params {

  if $ensure == 'present' {
    Class['nrpe::install'] -> Class['nrpe::config'] ~> Class['nrpe::service']
  } else {
    Class['nrpe::service'] -> Class['nrpe::config'] -> Class['nrpe::install']
  }

  contain nrpe::install
  contain nrpe::config
  contain nrpe::service
}

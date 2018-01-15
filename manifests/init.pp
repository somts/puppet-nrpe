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
  Enum[absent,present] $ensure             = $nrpe::params::ensure,
  Hash                 $commands           = $nrpe::params::commands,
  Hash                 $plugins            = $nrpe::params::plugins,
  String               $service            = $nrpe::params::service,
  Boolean              $service_status     = $nrpe::params::service_status,
  Boolean              $service_restart    = $nrpe::params::service_restart,
  Stdlib::Absolutepath $config_file        = $nrpe::params::configfile,
  String               $config_file_owner  = $nrpe::params::config_file_owner,
  String               $config_file_group  = $nrpe::params::config_group,
  String               $config_file_mode   = $nrpe::params::config_file_mode,
  String               $plugin_owner       = $nrpe::params::plugin_owner,
  String               $plugin_group       = $nrpe::params::plugin_group,
  String               $plugin_mode        = $nrpe::params::plugin_mode,
  Stdlib::Absolutepath $normal_etc         = $nrpe::params::normal_etc,
  Array                $allowed_hosts      = $nrpe::params::allowed_hosts,
  Integer              $command_timeout    = $nrpe::params::command_timeout,
  Integer              $connection_timeout = $nrpe::params::connection_timeout,
  Boolean              $debug              = $nrpe::params::debug,
  Boolean              $dont_blame_nrpe    = $nrpe::params::dont_blame_nrpe,
  Stdlib::Absolutepath $include_dir        = $nrpe::params::include_dir,
  String               $log_facility       = $nrpe::params::log_facility,
  String               $nrpe_group         = $nrpe::params::nrpe_group,
  String               $nrpe_user          = $nrpe::params::nrpe_user,
  Stdlib::Absolutepath $pid_file           = $nrpe::params::pid_file,
  Integer              $server_port        = $nrpe::params::server_port,
  String               $package            = $nrpe::params::package,
  Array                $plugins_packages   = $nrpe::params::plugins_packages,
  Stdlib::Absolutepath $pluginsdir         = $nrpe::params::pluginsdir,
  Stdlib::Absolutepath $sudoers_exe        = $nrpe::params::sudoers_exe,
  Boolean              $manage_firewall    = $nrpe::params::manage_firewall,
  String               $firewall_priority  = $nrpe::params::firewall_priority,
  Boolean              $zfs                = $nrpe::params::zfs,
  Boolean              $use_zfs_sudo       = $nrpe::params::use_zfs_sudo,
  Integer              $zfs_verbosity      = $nrpe::params::zfs_verbosity,
  Optional[String]     $ntp                = $nrpe::params::ntp,
  Optional[String]     $source             = $nrpe::params::source,
  Optional[String]     $content            = $nrpe::params::content,
  Optional[String]     $server             = $nrpe::params::server,
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

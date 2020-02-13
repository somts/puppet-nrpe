# Private class for init.pp
class nrpe::config {

  ### internal variables

  # Deal with ensuring things.
  $sym_ensure = $nrpe::ensure ? {
    'present' => 'link',
    default   => $nrpe::ensure,
  }
  $dir_ensure = $nrpe::ensure ? {
    'present' => 'directory',
    default   => $nrpe::ensure,
  }
  # set log_file to undef if we are not managing it
  $_log_file = $nrpe::manage_logfile ? {
    true  => $nrpe::log_file,
    false => undef,
  }
  $_log_facility = $nrpe::manage_logfile ? {
    true  => undef,
    false => $nrpe::log_facility,
  }

  $normal_cfg = "${nrpe::normal_etc}/nrpe.cfg"

  $settings = nrpe::hash2nrpe({
    log_facility                    => $_log_facility,
    log_file                        => $_log_file,
    debug                           => $nrpe::debug,
    pid_file                        => $nrpe::pid_file,
    server_port                     => $nrpe::server_port,
    server_address                  => $nrpe::server_address,
    listen_queue_size               => $nrpe::listen_queue_size,
    nrpe_user                       => $nrpe::nrpe_user,
    nrpe_group                      => $nrpe::nrpe_group,
    allowed_hosts                   => $nrpe::allowed_hosts,
    dont_blame_nrpe                 => $nrpe::dont_blame_nrpe,
    allow_bash_command_substitution => $nrpe::allow_bash_command_substitution,
    command_prefix                  => $nrpe::command_prefix,
    max_commands                    => $nrpe::max_commands,
    command_timeout                 => $nrpe::command_timeout,
    connection_timeout              => $nrpe::connection_timeout,
    allow_weak_random_seed          => $nrpe::allow_weak_random_seed,
    ssl_version                     => $nrpe::ssl_version,
    ssl_use_adh                     => $nrpe::ssl_use_adh,
    ssl_cipher_list                 => $nrpe::ssl_cipher_list,
    ssl_cacert_file                 => $nrpe::ssl_cacert_file,
    ssl_cert_file                   => $nrpe::ssl_cert_file,
    ssl_privatekey_file             => $nrpe::ssl_privatekey_file,
    ssl_client_certs                => $nrpe::ssl_client_certs,
    ssl_logging                     => $nrpe::ssl_logging,
    nasty_metachars                 => $nrpe::nasty_metachars,
    include                         => $nrpe::include,
    include_dir                     => $nrpe::include_dir,
  })

  $cfg_source = $nrpe::source ? {
    undef   => undef,
    default => $nrpe::source,
  }
  $cfg_content = $nrpe::content ? {
    undef   => $settings,
    default => $nrpe::content,
  }

  # Declare relations based on desired behavior
  if $nrpe::ensure == 'present' {
    Nrpe::Command { require => File['nrpe.d'] }
    Nrpe::Plugin  { require => File['nrpe.d'] }
  } else {
    Nrpe::Command { before => File['nrpe.d'] }
    Nrpe::Plugin  { before => File['nrpe.d'] }
  }

  ### managed resources

  file { 'nrpe.d':
    ensure => $dir_ensure,
    path   => $nrpe::include_dir,
    mode   => '0755',
    owner  => $nrpe::config_file_owner,
    group  => $nrpe::config_file_group,
  }

  file { 'nrpe.cfg':
    ensure  => $nrpe::ensure,
    path    => $nrpe::config_file,
    mode    => $nrpe::config_file_mode,
    owner   => $nrpe::config_file_owner,
    group   => $nrpe::config_file_group,
    source  => $cfg_source,
    content => $cfg_content,
  }

  # Convenience symlink.
  if $nrpe::config_file != $normal_cfg {
    file { $normal_cfg :
      ensure  => $sym_ensure,
      target  => $nrpe::config_file,
      owner   => $nrpe::config_file_owner,
      group   => $nrpe::config_file_group,
      require => File['nrpe.cfg'],
    }
  }

  create_resources('nrpe::plugin',$nrpe::plugins,{ ensure => $nrpe::ensure })
  create_resources('nrpe::command',$nrpe::commands,{ ensure => $nrpe::ensure })

  if $nrpe::manage_firewall      { contain nrpe::config::firewall }
  if $nrpe::manage_logfile       { contain nrpe::config::log      }
  if $nrpe::manage_checkntp      { contain nrpe::config::ntp      }
  if $nrpe::manage_checkzfs      { contain nrpe::config::zfs      }
  if $nrpe::manage_checkznapzend { contain nrpe::config::znapzend }
}

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

  $normal_cfg = "${nrpe::normal_etc}/nrpe.cfg"

  $settings = delete_undef_values({
    allowed_hosts      => $nrpe::allowed_hosts,
    command_timeout    => $nrpe::command_timeout,
    connection_timeout => $nrpe::connection_timeout,
    debug              => $nrpe::debug,
    dont_blame_nrpe    => $nrpe::dont_blame_nrpe,
    include_dir        => $nrpe::include_dir,
    log_facility       => $nrpe::log_facility,
    nrpe_group         => $nrpe::nrpe_group,
    nrpe_user          => $nrpe::nrpe_user,
    pid_file           => $nrpe::pid_file,
    server_port        => $nrpe::server_port,
  })
  $cfg_source = $nrpe::source ? {
    undef   => undef,
    default => $nrpe::source,
  }
  $cfg_content = $nrpe::content ? {
    undef   => template('nrpe/nrpe.cfg.erb'),
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

  if $nrpe::manage_firewall { contain nrpe::config::firewall }
  if $nrpe::ntp             { contain nrpe::config::ntp      }
  if $nrpe::zfs             { contain nrpe::config::zfs      }
}

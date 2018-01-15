# Set up a command in nrpe.d
define nrpe::command(
  Enum[absent,present] $ensure         = 'present',
  Boolean              $use_pluginsdir = true,
  Boolean              $use_sudo       = false,
  Optional[String]     $content        = undef,
  Optional[String]     $source         = undef,
  Optional[String]     $command        = undef,
) {
  # Validation
  if ($command == undef and $content == undef and $source == undef) {
    fail('Must set only one of command, content, or source parameters')
  }
  if (($command != undef and ($content !=undef or $source != undef)) or
  ($content != undef and $source != undef)){
    fail('Must set only one of $command, $content or $source')
  }

  include nrpe
  if $use_sudo { include sudo }

  $cmd = $use_pluginsdir ? {
    true  => "${nrpe::pluginsdir}/${command}",
    false => $command,
  }

  $cmd_wrapper = $use_sudo ? {
    true  => $nrpe::sudoers_exe,
    false => '', # lint:ignore:empty_string_assignment
  }

  $_content = $command ? {
    default => template('nrpe/command_cmd.erb'),
    undef   => $content ? {
      default => template('nrpe/command_content.erb'),
      undef   => undef
    },
  }

  file { "${nrpe::include_dir}/command-${name}.cfg":
    ensure  => $ensure,
    mode    => '0644',
    owner   => $nrpe::config_file_owner,
    group   => $nrpe::config_file_group,
    content => $_content,
    source  => $source,
    notify  => Class['nrpe::service'],
  }
}

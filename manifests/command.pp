# COMMAND DEFINITIONS
# Command definitions that this daemon will run.  Definitions
# are in the following format:
#
# command[<command_name>]=<command_line>
#
# When the daemon receives a request to return the results of <command_name>
# it will execute the command specified by the <command_line> argument.
#
# Unlike Nagios, the command line cannot contain macros - it must be
# typed exactly as it should be executed.
#
# Note: Any plugins that are used in the command lines must reside
# on the machine that this daemon is running on!  The examples below
# assume that you have plugins installed in a /usr/local/nagios/libexec
# directory.  Also note that you will have to modify the definitions below
# to match the argument format the plugins expect.  Remember, these are
# examples only!


# The following examples use hardcoded command arguments...
# This is by far the most secure method of using NRPE

#command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
#command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w .15,.10,.05 -c .30,.25,.20
#command[check_hda1]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/hda1
#command[check_zombie_procs]=/usr/lib64/nagios/plugins/check_procs -w 5 -c 10 -s Z
#command[check_total_procs]=/usr/lib64/nagios/plugins/check_procs -w 150 -c 200


# The following examples allow user-supplied arguments and can
# only be used if the NRPE daemon was compiled with support for
# command arguments *AND* the dont_blame_nrpe directive in this
# config file is set to '1'.  This poses a potential security risk, so
# make sure you read the SECURITY file before doing this.

### MISC SYSTEM METRICS ###
#command[check_users]=/usr/lib64/nagios/plugins/check_users $ARG1$
#command[check_load]=/usr/lib64/nagios/plugins/check_load $ARG1$
#command[check_disk]=/usr/lib64/nagios/plugins/check_disk $ARG1$
#command[check_swap]=/usr/lib64/nagios/plugins/check_swap $ARG1$
#command[check_cpu_stats]=/usr/lib64/nagios/plugins/check_cpu_stats.sh $ARG1$
#command[check_mem]=/usr/lib64/nagios/plugins/custom_check_mem -n $ARG1$

### GENERIC SERVICES ###
#command[check_init_service]=sudo /usr/lib64/nagios/plugins/check_init_service $ARG1$
#command[check_services]=/usr/lib64/nagios/plugins/check_services -p $ARG1$

### SYSTEM UPDATES ###
#command[check_yum]=/usr/lib64/nagios/plugins/check_yum
#command[check_apt]=/usr/lib64/nagios/plugins/check_apt

### PROCESSES ###
#command[check_all_procs]=/usr/lib64/nagios/plugins/custom_check_procs
#command[check_procs]=/usr/lib64/nagios/plugins/check_procs $ARG1$

### OPEN FILES ###
#command[check_open_files]=/usr/lib64/nagios/plugins/check_open_files.pl $ARG1$

### NETWORK CONNECTIONS ###
#command[check_netstat]=/usr/lib64/nagios/plugins/check_netstat.pl -p $ARG1$ $ARG2$

### ASTERISK ###
#command[check_asterisk]=/usr/lib64/nagios/plugins/check_asterisk.pl $ARG1$
#command[check_sip]=/usr/lib64/nagios/plugins/check_sip $ARG1$
#command[check_asterisk_sip_peers]=sudo /usr/lib64/nagios/plugins/check_asterisk_sip_peers.sh $ARG1$
#command[check_asterisk_version]=/usr/lib64/nagios/plugins/nagisk.pl -c version
#command[check_asterisk_peers]=/usr/lib64/nagios/plugins/nagisk.pl -c peers
#command[check_asterisk_channels]=/usr/lib64/nagios/plugins/nagisk.pl -c channels
#command[check_asterisk_zaptel]=/usr/lib64/nagios/plugins/nagisk.pl -c zaptel
#command[check_asterisk_span]=/usr/lib64/nagios/plugins/nagisk.pl -c span -s 1
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

  include 'nrpe'
  if $use_sudo { include 'sudo' }

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

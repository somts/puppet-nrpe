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
  $manage_logfile    = $::kernel ? {
    'FreeBSD' => true,
    'Linux'   => true,
    default   => false,
  }
  $firewall_priority    = '200'
  $manage_checkntp      = true
  $ntp                  = 'localhost'
  $source               = undef
  $content              = undef
  $server               = undef
  $manage_checkzfs      = false
  $manage_checkznapzend = false
  $zfs_verbosity        = 1 # anything higher breaks on Linux

  $use_zfs_sudo = $::osfamily ? {
    'RedHat' => true,
    default  => false,
  }

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
      'nagios-plugins-contrib',
      'nagios-plugins-extra',
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

  ### nrpe.cfg default settings

  # LOG FACILITY
  # The syslog facility that should be used for logging purposes.
  $log_facility = 'daemon'

  # LOG FILE
  # If a log file is specified in this option, nrpe will write to
  # that file instead of using syslog.
  #log_file='/var/log/nrpe.log'
  $log_file = '/var/log/nrpe.log'

  # DEBUGGING OPTION
  # This option determines whether or not debugging messages are logged to the
  # syslog facility.
  $debug = false

  # PID FILE
  # The name of the file in which the NRPE daemon should write it's process ID
  # number.  The file is only written if the NRPE daemon is started by the root
  # user and is running in standalone mode.
  $pid_file = $::osfamily ? {
    'Darwin'  => "${run}/nrpe/nrpe.lock",
    'FreeBSD' => "${run}/nrpe2/nrpe2.pid",
    'RedHat'  => "${run}/nrpe/nrpe.pid",
    default   => "${run}/nrpe.pid",
  }

  # PORT NUMBER
  # Port number we should wait for connections on.
  # NOTE: This must be a non-privileged port (i.e. > 1024).
  # NOTE: This option is ignored if NRPE is running under either inetd
  # or xinetd or via systemd. [In systemd please use
  # systemctl edit nrpe.service
  # to set up the port.
  $server_port = 5666

  # SERVER ADDRESS
  # Address that nrpe should bind to in case there are more than one interface
  # and you do not want nrpe to bind on all interfaces.
  # NOTE: This option is ignored if NRPE is running under either inetd or xinetd
  #       or with systemd. Please start by hand.
  $server_address = undef

  # LISTEN QUEUE SIZE
  # Listen queue size (backlog) for serving incoming connections.
  # You may want to increase this value under high load.
  $listen_queue_size = undef

  # NRPE USER
  # This determines the effective user that the NRPE daemon should run as.
  # You can either supply a username or a UID.
  #
  # NOTE: This option is ignored if NRPE is running under either inetd
  # or xinetd or via systemd. [In systemd please use
  # systemctl edit nrpe.service
  # to set up the group.
  $nrpe_user = $::osfamily ? {
    'RedHat' => 'nrpe',
    default  => 'nagios',
  }

  # NRPE GROUP
  # This determines the effective group that the NRPE daemon should run as.
  # You can either supply a group name or a GID.
  #
  # NOTE: This option is ignored if NRPE is running under either inetd
  # or xinetd or via systemd. [In systemd please use
  # systemctl edit nrpe.service
  # to set up the user.
  $nrpe_group = $::osfamily ? {
    'RedHat' => 'nrpe',
    default  => 'nagios',
  }

  # ALLOWED HOST ADDRESSES
  # This is an optional comma-delimited list of IP address or hostnames
  # that are allowed to talk to the NRPE daemon. Network addresses with a bit mask
  # (i.e. 192.168.1.0/24) are also supported. Hostname wildcards are not currently
  # supported.
  #
  # Note: The daemon only does rudimentary checking of the client's IP
  # address.  I would highly recommend adding entries in your /etc/hosts.allow
  # file to allow only the specified host to connect to the port
  # you are running this daemon on.
  #
  # NOTE: This option is ignored if NRPE is running under either inetd
  # or xinetd or systemd
  $allowed_hosts = ['127.0.0.1','::1']

  # COMMAND ARGUMENT PROCESSING
  # This option determines whether or not the NRPE daemon will allow clients
  # to specify arguments to commands that are executed.  This option only works
  # if the daemon was configured with the --enable-command-args configure script
  # option.
  #
  # *** ENABLING THIS OPTION IS A SECURITY RISK! ***
  # Read the SECURITY file for information on some of the security implications
  # of enabling this variable.
  #
  # Values: 0=do not allow arguments, 1=allow command arguments
  $dont_blame_nrpe = false

  # BASH COMMAND SUBSTITUTION
  # This option determines whether or not the NRPE daemon will allow clients
  # to specify arguments that contain bash command substitutions of the form
  # $(...).  This option only works if the daemon was configured with both
  # the --enable-command-args and --enable-bash-command-substitution configure
  # script options.
  #
  # *** ENABLING THIS OPTION IS A HIGH SECURITY RISK! ***
  # Read the SECURITY file for information on some of the security implications
  # of enabling this variable.
  #
  # Values: 0=do not allow bash command substitutions,
  #         1=allow bash command substitutions
  $allow_bash_command_substitution = false

  # COMMAND PREFIX
  # This option allows you to prefix all commands with a user-defined string.
  # A space is automatically added between the specified prefix string and the
  # command line from the command definition.
  #
  # *** THIS EXAMPLE MAY POSE A POTENTIAL SECURITY RISK, SO USE WITH CAUTION! ***
  # Usage scenario:
  # Execute restricted commmands using sudo.  For this to work, you need to add
  # the nagios user to your /etc/sudoers.  An example entry for allowing
  # execution of the plugins from might be:
  #
  # nagios          ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/
  #
  # This lets the nagios user run all commands in that directory (and only them)
  # without asking for a password.  If you do this, make sure you don't give
  # random users write access to that directory or its contents!
  $command_prefix = undef

  # MAX COMMANDS
  # This specifies how many children processes may be spawned at any one
  # time, essentially limiting the fork()s that occur.
  # Default (0) is set to unlimited
  $max_commands = 0

  # COMMAND TIMEOUT
  # This specifies the maximum number of seconds that the NRPE daemon will
  # allow plugins to finish executing before killing them off.
  $command_timeout = 60

  # CONNECTION TIMEOUT
  # This specifies the maximum number of seconds that the NRPE daemon will
  # wait for a connection to be established before exiting. This is sometimes
  # seen where a network problem stops the SSL being established even though
  # all network sessions are connected. This causes the nrpe daemons to
  # accumulate, eating system resources. Do not set this too low.
  $connection_timeout = 300

  # WEAK RANDOM SEED OPTION
  # This directive allows you to use SSL even if your system does not have
  # a /dev/random or /dev/urandom (on purpose or because the necessary patches
  # were not applied). The random number generator will be seeded from a file
  # which is either a file pointed to by the environment valiable $RANDFILE
  # or $HOME/.rnd. If neither exists, the pseudo random number generator will
  # be initialized and a warning will be issued.
  # Values: 0=only seed from /dev/[u]random, 1=also seed from weak randomness
  $allow_weak_random_seed = false

  # SSL/TLS OPTIONS
  # These directives allow you to specify how to use SSL/TLS.

  # SSL VERSION
  # This can be any of: SSLv2 (only use SSLv2), SSLv2+ (use any version),
  #        SSLv3 (only use SSLv3), SSLv3+ (use SSLv3 or above), TLSv1 (only use
  #        TLSv1), TLSv1+ (use TLSv1 or above), TLSv1.1 (only use TLSv1.1),
  #        TLSv1.1+ (use TLSv1.1 or above), TLSv1.2 (only use TLSv1.2),
  #        TLSv1.2+ (use TLSv1.2 or above)
  # If an "or above" version is used, the best will be negotiated. So if both
  # ends are able to do TLSv1.2 and use specify SSLv2, you will get TLSv1.2.
  # If you are using openssl 1.1.0 or above, the SSLv2 options are not available.
  #ssl_version=SSLv2+
  $ssl_version = undef

  # SSL USE ADH
  # This is for backward compatibility and is DEPRECATED. Set to 1 to enable
  # ADH or 2 to require ADH. 1 is currently the default but will be changed
  # in a later version.
  $ssl_use_adh = undef

  # SSL CIPHER LIST
  # This lists which ciphers can be used. For backward compatibility, this
  # defaults to 'ssl_cipher_list=ALL:!MD5:@STRENGTH' for < OpenSSL 1.1.0,
  # and 'ssl_cipher_list=ALL:!MD5:@STRENGTH:@SECLEVEL=0' for OpenSSL 1.1.0 and
  # greater.

  #ssl_cipher_list=ALL:!MD5:@STRENGTH
  #ssl_cipher_list=ALL:!MD5:@STRENGTH:@SECLEVEL=0
  #ssl_cipher_list=ALL:!aNULL:!eNULL:!SSLv2:!LOW:!EXP:!RC4:!MD5:@STRENGTH
  $ssl_cipher_list = undef

  # SSL Certificate and Private Key Files
  #ssl_cacert_file=/etc/ssl/servercerts/ca-cert.pem
  #ssl_cert_file=/etc/ssl/servercerts/nagios-cert.pem
  #ssl_privatekey_file=/etc/ssl/servercerts/nagios-key.pem
  $ssl_cacert_file     = undef
  $ssl_cert_file       = undef
  $ssl_privatekey_file = undef

  # SSL USE CLIENT CERTS
  # This options determines client certificate usage.
  # Values: 0 = Don't ask for or require client certificates (default)
  #         1 = Ask for client certificates
  #         2 = Require client certificates
  $ssl_client_certs = 0

  # SSL LOGGING
  # This option determines which SSL messages are send to syslog. OR values
  # together to specify multiple options.

  # Values: 0x00 (0)  = No additional logging (default)
  #         0x01 (1)  = Log startup SSL/TLS parameters
  #         0x02 (2)  = Log remote IP address
  #         0x04 (4)  = Log SSL/TLS version of connections
  #         0x08 (8)  = Log which cipher is being used for the connection
  #         0x10 (16) = Log if client has a certificate
  #         0x20 (32) = Log details of client's certificate if it has one
  #         -1 or 0xff or 0x2f = All of the above
  $ssl_logging = '0x00'

  # NASTY METACHARACTERS
  # This option allows you to override the list of characters that cannot
  # be passed to the NRPE daemon.
  # nasty_metachars="|`&><'\\[]{};\r\n"
  $nasty_metachars = undef

  # INCLUDE CONFIG FILE
  # This directive allows you to include definitions from an external config file.
  #include=<somefile.cfg>
  $include = undef

  # INCLUDE CONFIG DIRECTORY
  # This directive allows you to include definitions from config files (with a
  # .cfg extension) in one or more directories (with recursion).

  #include_dir=<somedirectory>
  #include_dir=<someotherdirectory>
  $include_dir = $::osfamily ? {
    'Darwin' => "${etc}/nrpe/nrpe.d",
    'Debian' => "${etc}/nagios/nrpe.d",
    'RedHat' => "${etc}/nagios/nrpe.d",
    default  => "${etc}/nrpe.d",
  }
}

# Private class for init.pp
# Many OSes can install ZFS, so install the NRPE check for ZFS as well
# as ZnapZend logs when certain classes are defined.
class nrpe::config::zfs {

  nrpe::plugin { 'check_zfs':
    ensure => $nrpe::ensure,
    source => 'puppet:///modules/nrpe/plugins/check_zfs',
  }
  nrpe::command { 'check_zfs':
    ensure   => $nrpe::ensure,
    use_sudo => $nrpe::use_zfs_sudo,
    command  => "check_zfs \$ARG1\$ ${nrpe::zfs_verbosity} \$ARG2\$ \$ARG3\$",
  }
  nrpe::plugin { 'check_znapzend_log':
    ensure => $nrpe::ensure,
    source => 'puppet:///modules/nrpe/plugins/check_znapzend_log',
  }
  nrpe::command { 'check_znapzend_log':
    ensure   => $nrpe::ensure,
    use_sudo => false,
    command  => "check_znapzend_log \$ARG1\$",
  }

  if $nrpe::use_zfs_sudo {
    sudo::conf { 'nrpe-allow-check_zfs':
      content  => join([
        "User_Alias CHECKZFS_USERS = ${nrpe::nrpe_user},%wheel",
        "CHECKZFS_USERS ALL=(ALL) NOPASSWD: ${nrpe::pluginsdir}/check_zfs",
      ],"\n"),
    }
  }
}

# Private class for init.pp
# NRPE check for ZFS
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

  if $nrpe::use_zfs_sudo {
    sudo::conf { 'nrpe-allow-check_zfs':
      ensure  => $nrpe::ensure,
      content => join([
        "User_Alias CHECKZFS_USERS = ${nrpe::nrpe_user},%wheel",
        "CHECKZFS_USERS ALL=(ALL) NOPASSWD: ${nrpe::pluginsdir}/check_zfs",
      ],"\n"),
    }
  }
}

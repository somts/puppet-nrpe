# Private class for init.pp
# Check ZnapZend logs.
class nrpe::config::znapzend {
  nrpe::plugin { 'check_znapzend_log':
    ensure => $nrpe::ensure,
    source => 'puppet:///modules/nrpe/plugins/check_znapzend_log',
  }
  nrpe::command { 'check_znapzend_log':
    ensure  => $nrpe::ensure,
    command => "check_znapzend_log \$ARG1\$",
  }
}

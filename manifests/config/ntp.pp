# Private class for init.pp
# Add an NTP check.
class nrpe::config::ntp {
  nrpe::command { 'check_ntp':
    ensure  => $nrpe::ensure,
    command => "check_ntp -H ${nrpe::ntp}",
  }
}

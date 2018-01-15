# Private class for init.pp
class nrpe::install {
  package { 'nrpe':
    ensure => $nrpe::ensure,
    name   => $nrpe::package,
  }
  -> package { $nrpe::plugins_packages :
    ensure => $nrpe::ensure,
  }
}

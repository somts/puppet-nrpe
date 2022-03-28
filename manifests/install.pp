# Private class for init.pp
class nrpe::install {
  # This class only makes sense when called from init.pp
  assert_private("Must only be called by ${module_name}")

  package { 'nrpe':
    ensure => $nrpe::ensure,
    name   => $nrpe::package,
  }
  -> package { $nrpe::plugins_packages :
    ensure => $nrpe::ensure,
  }
}

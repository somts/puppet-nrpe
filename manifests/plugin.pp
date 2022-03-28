# Define: nrpe::plugin
#
# Install an NRPE plugin from a Puppet resource into the NRPE plugin dir.
#
define nrpe::plugin(
  Enum['absent', 'present'] $ensure  = 'present',
  Optional[String] $content = undef,
  Optional[String] $source  = undef,
) {
  if $source != undef and $content != undef {
    fail('Cannot set multiple of $content or $source')
  }
  if $source == undef and $content == undef {
    fail('Must set $content or $source')
  }

  include 'nrpe'

  file { $name :
    ensure  => $ensure,
    path    => "${nrpe::pluginsdir}/${name}",
    mode    => $nrpe::plugin_mode,
    owner   => $nrpe::plugin_owner,
    group   => $nrpe::plugin_group,
    source  => $source,
    content => $content,
    notify  => Class['nrpe::service'],
  }
}

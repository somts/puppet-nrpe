# Private class for init.pp
class nrpe::service {
  # This class only makes sense when called from init.pp
  assert_private("Must only be called by ${module_name}")

  # internal variables

  # Deal with ensuring things.
  $svc_enable = $nrpe::ensure ? { 'absent' => false, default => true }
  $svc_ensure = $nrpe::ensure ? { 'absent' => 'stopped', default => 'running' }

  service { 'nrpe':
    ensure    => $svc_ensure,
    enable    => $svc_enable,
    name      => $nrpe::service,
    hasstatus => $nrpe::service_status,
  }
}

# Configure NRPE firewall
class nrpe::config::firewall {
  # This class only makes sense when called from init.pp
  assert_private("Must only be called by ${module_name}")

  $fw_defaults = {
    ensure   => $nrpe::ensure,
    action   => 'accept',
    ctstate  => 'NEW',
    proto    => 'tcp',
    dport    => $nrpe::server_port,
  }

  $nrpe::allowed_hosts.each |String $host| {

    unless $host in ['127.0.0.1','::1'] { # Skip localhost
      if is_ipv6_address($host)  {
        if !defined(Firewall["${nrpe::firewall_priority} IPv6 NRPE ${host}"]) {
          firewall { "${nrpe::firewall_priority} IPv6 NRPE ${host}":
            * => $fw_defaults + { source => $host, provider => 'ip6tables' },
          }
        }
      } else {
        if !defined(Firewall["${nrpe::firewall_priority} IPv4 NRPE ${host}"]) {
          firewall { "${nrpe::firewall_priority} IPv4 NRPE ${host}":
            * => $fw_defaults + { source => $host },
          }
        }
      }
    }
  }
}

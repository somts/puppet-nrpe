# Configure NRPE firewall
class nrpe::config::firewall {
  $nrpe::allowed_hosts.each |String $host| {
    unless $host in ['127.0.0.1','::1'] { # Skip localhost
      firewall { "${nrpe::firewall_priority} NRPE ${host}":
        action  => 'accept',
        ctstate => 'NEW',
        source  => $host,
        proto   => 'tcp',
        dport   => $nrpe::server_port,
      }
    }
  }
}

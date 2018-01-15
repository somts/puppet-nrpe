class nrpe::config::firewall {
  $nrpe::allowed_hosts.each |String $host| {

    if $host != '127.0.0.1' { # Skip IPv4 localhost
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

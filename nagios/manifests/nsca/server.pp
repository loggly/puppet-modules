class nagios::nsca::server {
  include ::nagios::nsca

  # Enable nsca (service defined in nagios::nsca)
  Service <| title == "nsca" |> {
    ensure => running,
    enable => true,
  }

  file {
    "/etc/nsca.cfg":
      ensure => file,
      content => template("nagios/nsca/nsca.cfg.erb"),
      notify => Service["nsca"];
  }

  iptables::rule {
    # TODO(sissel): allow specifying 'all known hosts'
    # For now, allowing any private net to submit is fine since
    # NSCA uses encryption with a pre-shared key.
    "allow nsca submission":
      ports => [ 5667 ],
      sources => [ "10.0.0.0/8" ];
  }
}

class nagios::nrpe::package {
  package {
    "nagios-nrpe-server":
      ensure => latest;
  }
}

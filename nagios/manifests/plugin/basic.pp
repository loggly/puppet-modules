class nagios::plugin::basic {
  package {
    "nagios-plugins-basic":
      ensure => latest;
  }
}

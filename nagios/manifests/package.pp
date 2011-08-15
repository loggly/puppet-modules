class nagios::package {
  include ::apache::server
  package {
    "nagios3":
      ensure => latest,
      notify => Class["apache::server"];
  }

  file {
    "/etc/nagios3/hosts.d":
      ensure => directory;
    "/etc/nagios3/checks.d":
      ensure => directory;
  }
}

class nagios::user::logwatcher {
  # Add to user 'adm' so it can read files generated by syslog on Ubuntu.
  user {
    "logwatcher":
      ensure => present,
      groups => [ "adm" ];
  }
}
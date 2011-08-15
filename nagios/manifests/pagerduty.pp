class nagios::pagerduty {
  package {
    "libwww-perl":
      ensure => latest;
    "libcrypt-ssleay-perl":
      ensure => latest;
  }

  nagios::config {
    "pagerduty":
      source => "puppet:///modules/nagios/pagerduty/pagerduty.cfg";
  }

  file {
    "/usr/local/bin/pagerduty_nagios.pl":
      ensure => file,
      source => "puppet:///modules/nagios/pagerduty/pagerduty_nagios.pl",
      mode => 755;
  }

  file {
    "/etc/cron.d/pagerdutynagios":
      ensure => file,
      content => "* * * * * nagios /usr/local/bin/pagerduty_nagios.pl flush\n";
  }
}

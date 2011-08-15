class nagios::nrpe::server {
  include ::nagios::nrpe::package
  include ::nagios::user

  file {
    "/etc/nagios/nrpe.cfg":
      ensure => file,
      source => "puppet:///modules/nagios/nrpe/nrpe.cfg",
      notify => Service["nagios-nrpe-server"];
  }

  service {
    "nagios-nrpe-server":
      ensure => running,
      enable => true,
      status => "pgrep -f '/usr/sbin/nrpe -c '";
  }

  iptables::rule {
    "allow nrpe":
      ports => 5666,
      roles => ["monitor"];
  }
}

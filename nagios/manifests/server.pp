class nagios::server {
  include ::apache::server
  include ::nagios::package

  service {
    "nagios3":
      ensure => running,
      enable => true,
      require => Package["nagios3"],
      hasrestart => true,
      hasstatus => true;
  }
  
  file {
    # Remove the crap installed by the nagios3 ubuntu package
    [ "/etc/nagios3/conf.d/host-gateway_nagios3.cfg",
      "/etc/nagios3/conf.d/localhost_nagios2.cfg",
      "/etc/nagios3/conf.d/services_nagios2.cfg",
      "/etc/nagios3/conf.d/hostgroups_nagios2.cfg",
      "/etc/nagios3/conf.d/timeperiods_nagios2.cfg",
      "/etc/nagios3/conf.d/contacts_nagios2.cfg",
      "/etc/nagios3/conf.d/extinfo_nagios2.cfg",
      "/etc/nagios3/conf.d/generic-host_nagios2.cfg",
      "/etc/nagios3/conf.d/generic-service_nagios2.cfg"]:
      ensure => absent,
      notify => Service["nagios3"];
    "/etc/nagios3/htpasswd.users":
      ensure => file,
      content => extlookup("nagios/htpasswd");
    "/etc/nagios3/cgi.cfg":
      ensure => file,
      notify => Service["nagios3"],
      source => "puppet:///modules/nagios/cgi.cfg";
    "/etc/nagios3/nagios.cfg":
      ensure => file,
      notify => Service["nagios3"],
      source => "puppet:///modules/nagios/nagios.cfg";
    "/var/lib/nagios3":
      ensure => directory,
      owner => "nagios",
      group => "www-data",
      mode => 751;
    "/var/lib/nagios3/rw":
      ensure => directory,
      owner => "nagios",
      group => "www-data",
      mode => 2771;
  }

  exec {
    # https://bugs.launchpad.net/ubuntu/+source/nagios3/+bug/387069
    # Debian/Ubuntu have a wontfix bug that requires manual intervention to use
    # a common nagios feature.
    "fix nagios.cmd permissions":
      command => "dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw; dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3; true",
      before => Service["nagios3"];
    "really fix nagios.cmd permissions":
      command => "chown nagios:www-data /var/lib/nagios3/rw;
                  chmod 2710 /var/lib/nagios3/rw;
                  chown nagios:www-data /var/lib/nagios3/rw/nagios.cmd;
                  chmod 0660 /var/lib/nagios3/rw/nagios.cmd; true",
      before => Service["nagios3"];
  }

  apache::config {
    "nagios3":
      source => "file:///etc/nagios3/apache2.conf",
      require => File["/var/lib/nagios3/rw"];
  }

  iptables::rule {
    "allow nagios":
      ports => 80;
  }

}

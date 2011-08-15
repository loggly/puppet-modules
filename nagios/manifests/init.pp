class nagios {
  include ::nagios::package
  include ::nagios::server
  include ::nagios::user
  include ::nagios::pagerduty
  include ::nagios::nsca::server

  nagios::config {
    "hosts": ensure => absent;
    "services": ensure => absent;

    "contacts": source => "puppet:///modules/nagios/contacts.cfg";
    "timeperiods": source => "puppet:///modules/nagios/timeperiods.cfg";

    "hosts-base": source => "puppet:///modules/nagios/hosts-base.cfg";
    "services-base": source => "puppet:///modules/nagios/services-base.cfg";
    #"hosts-$deployment": content => template("nagios/hosts-deployment.cfg.erb");
    #"services-$deployment": content => template("nagios/hosts-deployment.cfg.erb");
  }   

  $loggly_nagios_input = extlookup("nagios/loggly-input", "undefined")

  file {
    "/usr/local/bin/nagios-to-loggly.rb":
      ensure => file,
      source => "puppet:///modules/nagios/nagios-to-loggly.rb",
      mode => 755;
  }

  nagios::command {
    "noop":
      command => "/bin/true",
      remote => false;
    "log-to-loggly":
      command => "/usr/local/bin/nagios-to-loggly.rb -u $loggly_nagios_input",
      require => File["/usr/local/bin/nagios-to-loggly.rb"],
      remote => false;
  }

  Nagios::Host <<| tag == "deployment::$deployment" |>> {
    notify => Class["nagios::server"]
  }

  Nagios::Check <<| tag == "deployment::$deployment" |>> {
    notify => Class["nagios::server"]
  }

  # Clean up any files that haven't been touched in a day.
  tidy {
    [ "/etc/nagios3/hosts.d", "/etc/nagios3/checks.d" ]:
      age => 1d,
      notify => Class["nagios::server"],
      recurse => true,
      matches => [ "*.cfg" ];
  }
}

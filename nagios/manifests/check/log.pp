define nagios::check::log($files, $patterns, $user="logwatcher",
                          $contacts=undef, $ensure="present") {
  include ::nagios::nsca
  include ::nagios::user::logwatcher
  include ::grok::package
  include ::ruby::gem::eventmachine-tail

  $host = $fqdn
  $monitor_host = "monitor"
  $check_name = "$name on $fqdn"

  $safename = regsubst($name, " ", "-", "G")
  $grok_config = "/etc/grok.d/${safename}.grok"
  $procname = "monitor-$safename"

  file {
    # TODO(sissel): Safe to remove after 2011/01/01
    "/etc/grok.d/${name}.grok":
      ensure => absent;
    $grok_config:
      ensure => $ensure ? { "present" => "file", "absent" => "absent" },
      notify => Supervisor::Program[$procname],
      content => template("nagios/check/log.grok.erb");
  }

  if ($ensure == "present") {
    @@nagios::check {
      $check_name:
        passive => true,
        volatile => true,
        contacts => $contacts,
        max_failures => 1,
        host => $fqdn,
        tag => "deployment::$deployment";
    }
  }

  supervisor::program {
    $procname:
      ensure => $ensure,
      command => "grok -f '$grok_config'",
      user => $user,
      require => [File[$grok_config], Class["grok::package", "nagios::nsca"]];
  }
}

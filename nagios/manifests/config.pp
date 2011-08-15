define nagios::config($source = undef, $content = undef, $ensure = "present") {
  include ::nagios::server
  include ::nagios::package

  if ($ensure != "absent") {
    if ($content == undef and $source == undef) {
      error("You must specify only one of 'content' or 'source' for $class[$name]")
    }
    if ($content != undef and $source != undef) {
      error("You must specify only one of 'content' or 'source' for $class[$name]")
    }
  }

  file {
    "/etc/nagios3/conf.d/$name.cfg":
      ensure => $ensure ? { "present" => file, default => absent },
      source => $source,
      content => $content,
      require => Class["nagios::package"],
      notify => Class["nagios::server"];
  }
}

define nagios::host($address) {
  $file = "/etc/nagios3/hosts.d/$name.cfg"
  nagios_host {
    "$name":
      target => $file,
      use => "base-host",
      require => File["/etc/nagios3/hosts.d"],
      address => "$address",
      alias => "$name ($address)",
  }

  file {
    $file: 
      ensure => file,
      require => Nagios_host[$name],
      owner => nagios,
      mode => 644;
  }
}

class apt {
  file {
    "/etc/apt/apt.conf.d/90sanity":
      ensure => file,
      source => "puppet:///modules/apt/sanity.apt.conf";
    "/usr/local/bin/stripdeb.sh":
      ensure => file,
      source => "puppet:///modules/apt/stripdeb.sh",
      mode => 755;
    "/etc/apt/apt.conf.d/90stripdeb":
      ensure => absent, # TODO(sissel): Want a better way to selectively strip packages
      source => "puppet:///modules/apt/stripdeb.apt.conf";
  }
}

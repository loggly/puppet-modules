class nagios::nsca {
  package {
    "nsca": ensure => latest;
  }

  # Disable nsca by default.
  service {
    "nsca":
      ensure => stopped,
      enable => true,
      require => Package["nsca"];
  }

  file {
    "/etc/send_nsca.cfg":
      ensure => file,
      content => template("nagios/nsca/send_nsca.cfg.erb");
  }
}

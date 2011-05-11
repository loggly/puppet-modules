class debian::preseed {
  $basepath = "/var/lib/puppet-preseed"

  file {
    $basepath:
      ensure => directory;
  }
}

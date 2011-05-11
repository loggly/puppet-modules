define debian::package($ensure="present", $config) {
  include ::debian::preseed

  $responsefile = "$debian::preseed::basepath/$name.preseed"
  package {
    "$name":
      ensure => $ensure,
      responsefile => $responsefile,
      require => File[$responsefile];
  }

  file {
    $responsefile:
      ensure => file,
      content => template("debian/preseed.erb");
  }
}

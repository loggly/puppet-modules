class truth {
  include ::loggly::rightscale
  include ::loggly::common

  package {
    "libjson-ruby":
      ensure => latest;
    "python-zerigodns":
      ensure => latest;
  }

  file {
    "/opt/loggly/truth":
      ensure => directory;
    "/opt/loggly/truth/bin":
      ensure => directory;
    "/opt/loggly/truth/bin/query-rightscale.py":
      ensure => file,
      source => "puppet:///modules/truth/query-rightscale.py",
      mode => 755;
  }

  exec {
    "update zerigo dns":
      command => "python /opt/puppet/modules/truth/files/update-zerigo.py",
      require => Package["python-zerigodns"];
  }
}

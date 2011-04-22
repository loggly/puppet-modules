class loggly::buildserver {
  include ::ubuntu::packagebuilding
  include ::loggly::common
  include ::jenkins
  include ::java::jdk

  # TODO(sissel): make this allow only known hosts?
  iptables::rule {
    "allow http":
      ports => 80;
  }

  package {
    "reprepro": ensure => latest;
    "gnupg": ensure => latest;
    "ant": ensure => latest;
  }

  user {
    "pkgrepo": ensure => present;
  }

  nginx::vhost {
    "repo":
      source => "puppet:///modules/loggly/buildserver/repo.nginx.conf";
    "jenkins":
      source => "puppet:///modules/loggly/buildserver/jenkins.nginx.conf";
  }

  file {
    "/mnt/loggly/repo":
      ensure => directory,
      owner => "pkgrepo";
    "/opt/loggly/repo":
      ensure => link,
      target => "/mnt/loggly/repo";
    "/opt/loggly/repo/conf":
      ensure => directory;
    "/opt/loggly/repo/conf/distributions":
      ensure => file,
      source => "puppet:///modules/loggly/buildserver/distributions";
    "/opt/loggly/repo/gpg":
      ensure => directory,
      owner => "pkgrepo",
      mode => 700;
    "/opt/loggly/repo/gpg/pubring.gpg":
      ensure => file,
      source => "puppet:///modules/loggly/buildserver/gpg/pubring.gpg",
      owner => "pkgrepo",
      mode => 600;
    "/opt/loggly/repo/gpg/secring.gpg":
      ensure => file,
      source => "puppet:///modules/loggly/buildserver/gpg/secring.gpg",
      owner => "pkgrepo",
      mode => 600;
    "/opt/loggly/repo/gpg/trustdb.gpg":
      ensure => file,
      source => "puppet:///modules/loggly/buildserver/gpg/trustdb.gpg",
      owner => "pkgrepo",
      mode => 600;
    "/usr/local/bin/publish.sh":
      ensure => file,
      source => "puppet:///modules/loggly/buildserver/publish.sh",
      mode => 755;
    "/usr/local/bin/genrepo.sh":
      ensure => file,
      source => "puppet:///modules/loggly/buildserver/genrepo.sh",
      mode => 755;
  }
}

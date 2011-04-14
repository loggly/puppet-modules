class user::humans {
  user::managed {
    "someuser": ensure => present, root => true;
    "anotherguy": ensure => present, root => true;
    "an_ex_employee": ensure => present, shell => "/usr/sbin/nologin", root => false;
  }

  package {
    "loggly-homedirs":
      ensure => latest,
      notify => Exec["refresh homedirs"];
  }

  exec {
    "refresh homedirs":
      command => "sh /opt/homedirs/postinst configure",
      refreshonly => true;
  }

  # Only update/install loggly-homedirs package after we have
  # handled all users. Otherwise some user homedirs won't exist
  # on the first run.
  User <| |> {
    before +> [Package["loggly-homedirs"], Exec["refresh homedirs"]],
  }
}


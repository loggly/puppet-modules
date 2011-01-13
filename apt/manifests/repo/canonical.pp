class apt::repo::canonical {
  include ::apt::refresh

  file {
    "/etc/apt/sources.list.d/canonical.list":
      ensure => file,
      source => "puppet:///modules/apt/repo/canonical/canonical.list";
    "/etc/apt/canonical.key":
      ensure => file,
      source => "puppet:///modules/apt/repo/canonical/canonical.key",
      notify => Exec["add canonical apt key"];
  }

  exec {
    "add canonical apt key":
      command => "apt-key add /etc/apt/canonical.key",
      refreshonly => true;
  }

}

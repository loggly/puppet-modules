class apt::repo::cloudera {
  file {
    "/etc/apt/sources.list.d/cloudera.list":
      ensure => file,
      source => "puppet:///modules/apt/repo/cloudera/cloudera.list";

    # apt key downloaded from http://archive.cloudera.com/debian/archive.key
    "/etc/apt/sources.list.d/cloudera.key":
      ensure => file,
      source => "puppet:///modules/apt/repo/cloudera/cloudera.key";
  }
}

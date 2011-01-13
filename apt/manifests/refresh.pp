class apt::refresh {
  exec {
    "fetch latest apt data":
      command => "apt-get update -qqy",
      returns => [0, 100],
      refreshonly => true;
  }
}

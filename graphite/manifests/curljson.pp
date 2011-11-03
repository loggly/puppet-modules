define graphite::curljson($url, $filter=[], $metric_prefix="",
                          $interval=10) {
  require ::graphite::tools

  file {
    "/usr/local/bin/curljson-$name.sh":
      ensure => file,
      content => template("graphite/tools/curl-json-to-graphite.sh.erb"),
      notify => Supervisor::Program["curljson-$name"],
      mode => 755;
  }

  supervisor::program {
    "curljson-$name":
      command => "/usr/local/bin/curljson-$name.sh",
      user => "nobody";
  }
}

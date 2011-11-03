class graphite::tools {
  include ::nodejs

  file {
    "/usr/local/bin/json-to-graphite.js":
      source => "puppet:///modules/graphite/tools/json-to-graphite.js",
      require => Class["nodejs"];
  }
}

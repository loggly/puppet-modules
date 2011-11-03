class graphite::server {
  include ::graphite::package
  include ::apache::mod::wsgi

  user {
    "graphite": ensure => present;
  }

  iptables::rule {
    "allow http (for graphite)": ports => 80;
    "allow https (for graphite)": ports => 443;
  }

  file {
    "/mnt/graphite":
      ensure => directory,
      owner => "graphite";
    "/mnt/graphite/storage":
      ensure => directory,
      owner => "graphite";
    "/mnt/graphite/storage/whisper":
      ensure => directory,
      owner => "graphite",
      recurse => "true";
    "/mnt/graphite/storage/log":
      ensure => directory,
      owner => "graphite";
    "/opt/graphite/conf/carbon.conf":
      ensure => file,
      owner => "graphite",
      source => "puppet:///modules/graphite/carbon.conf",
      require => Class["graphite::package"],
      notify => Supervisor::Program["graphite-carbon"];
    "/opt/graphite/conf/storage-schemas.conf":
      ensure => file,
      owner => "graphite",
      source => "puppet:///modules/graphite/storage-schemas.conf",
      require => Class["graphite::package"],
      notify => Supervisor::Program["graphite-carbon"];
    "/opt/graphite/webapp":
      ensure => directory;
    "/opt/graphite/webapp/graphite/graphite.wsgi":
      ensure => file,
      source => "puppet:///modules/graphite/graphite.wsgi";
    "/opt/graphite":
      ensure => directory,
      owner => "graphite",
      recurse => true;
    "/opt/graphite/storage/whisper":
      ensure => link,
      force => true,
      target => "/mnt/graphite/storage/whisper";
    "/opt/graphite/storage/log":
      ensure => link,
      force => true,
      target => "/mnt/graphite/storage/log";
    "/opt/graphite/storage/log/webapp":
      ensure => directory,
      owner => "www-data";
    [ "/opt/graphite/storage/log/webapp/exception.log",
      "/opt/graphite/storage/log/webapp/info.log" ]:
      ensure => file,
      owner => "www-data";

    "/opt/graphite/storage/webapp":
      ensure => directory,
      owner => "www-data";
    "/opt/graphite/webapp/graphite/local_settings.py":
      ensure => file,
      source => "puppet:///modules/graphite/local_settings.py";

    # graphite-web likes to have write access to this file, but it doesn't
    # actually write to it? Confusing. -jordan
    "/mnt/graphite/storage/index":
      ensure => file,
      owner => "www-data";
  }

  iptables::rule {
    "allow metric pushes to graphite":
      ports => [ 2003 ],
      roles => [ "solr", "proxy", "frontend", "graphite", "monitor" ];
  }

  supervisor::program {
    "grophite-web":
      user => "graphite", 
      command => "python /opt/graphite/bin/run-graphite-devel-server.py /opt/graphite",
      ensure => absent; # Don't need this anymore, remove after 2011/12/01
    "graphite-carbon":
      user => "graphite",
      command => "python /opt/graphite/bin/carbon-cache.py --debug start",
      require => [Class["graphite::package"], File["/mnt/graphite/storage/whisper"]];
  }

  apache::site {
    "graphite":
      content => template("graphite/graphite.httpd.conf.erb");
  }
}

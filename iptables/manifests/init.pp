class iptables {
  package {
    "conntrack": ensure => latest;
  }

  file {
    [ "/etc/iptables.d", "/etc/iptables.d/nat", "/etc/iptables.d/filter" ]:
      ensure => directory;
    "/usr/local/bin/build-iptables.rb":
      ensure => file,
      source => "puppet:///modules/iptables/build-iptables.rb",
      mode => 755;

    "/etc/iptables.d/filter/1.basic":
      ensure => file,
      source => "puppet:///modules/iptables/1.basic";
    "/etc/iptables.d/filter/1000.drop-unexpected":
      ensure => file,
      source => "puppet:///modules/iptables/1000.drop-unexpected";
    "/etc/iptables.d/filter/999.iptables-logging":
      ensure => file,
      source => "puppet:///modules/iptables/999.iptables-logging";
  }
}

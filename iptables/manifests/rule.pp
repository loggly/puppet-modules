define iptables::rule($ports, $protocol="tcp", $ensure="permit", $roles=undef,
                      $sources=undef, $priority=10) {
  include ::iptables

  # Validate $ensure
  case $ensure {
    "permit": { $target = "ACCEPT" }
    "reject": { $target = "REJECT" }
    "drop": { $target = "DROP" }
    default: { fail("Invalid value ensure => '$ensure' for Iptables::Rule[$name]. Must be permit, reject, or drop") }
  }

  # Validate $protocol
  case $protocol {
    "tcp", "icmp", "udp": { }
    default: { fail("Invalid value protocol => '$protocol' for Iptables::Rule[$name]. Must be tcp, icmp, or udp") }
  }

  # If no roles or sources are specified, default to 'any'
  if $roles == undef and $sources == undef {
    $any_source = true
  } else {
    $any_source = false
  }

  $file_name = inline_template("<%= priority + '.' + name.gsub(' ', '_') %>")
  file {
    [ "/etc/iptables.d/iptables.$name",
      "/etc/iptables.d/filter/iptables.$name",
      "/etc/iptables.d/filter/$priority.$name" ]:
      ensure => absent;
    "/etc/iptables.d/filter/$file_name":
      ensure => file,
      content => template("iptables/rule.erb");
  }
}

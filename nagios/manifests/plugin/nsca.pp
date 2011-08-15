class nagios::plugin::nsca {
  include ::nagios::nsca::server

  nagios::command {
    "remotecheck":
      command => "/usr/lib/nagios/plugins/check_nrpe -H \$HOSTADDRESS\$ -t 600 -c \$ARG1\$",
      remote => false; # this command runs on the nagios server
  }
}

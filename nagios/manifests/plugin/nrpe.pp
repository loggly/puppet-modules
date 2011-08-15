class nagios::plugin::nrpe {
  package {
    "nagios-nrpe-plugin":
      ensure => latest;
  }

  nagios::command {
    "remotecheck":
      command => "/usr/lib/nagios/plugins/check_nrpe -H \$HOSTADDRESS\$ -t 600 -c \$ARG1\$",
      remote => false; # this command runs on the nagios server
  }
}

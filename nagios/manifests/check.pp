# This vim modeline is needed because otherwise vim thinks this file is a bindzone.
# vim:set ft=puppet:

define nagios::check($command=undef, $host, $remote=false, $contacts="default",
                     $passive=false, $volatile=false, $max_failures=3) {
  $safe_name = inline_template("<%= name.gsub(/[ '\"]/, ' ') %>")
  $file = "/etc/nagios3/checks.d/check-$host-$safe_name.cfg"

  if $command == undef and $passive == false {
    fail("A command is required if passive false.")
  }

  if $remote {
    include ::nagios::plugin::nrpe
    $check_command = "remotecheck!$command"

    Nagios_service <| title == $name |> {
      require +> Class["nagios::plugin::nrpe"]
    }
    $notes = "NRPE: check_nrpe -H $fqdn -t 600 -c $command"
  } elsif $passive {
    $check_command = "noop"
    $notes = "Passive check. No command."
  } else {
    $check_command = $command
    $notes = "Command: $command"
  }

  nagios_service {
    "$name":
      target => "$file",
      check_command => $check_command,
      host_name => "$host",
      require => File["/etc/nagios3/checks.d"],
      notes => $notes,
      contacts => $contacts,
      service_description => "$name",
      notification_period => extlookup("nagios/notificationperiod", "24x7"),
      active_checks_enabled => $passive ? { true => 0, false => 1 },
      passive_checks_enabled => $passive ? { true => 1, false => 0 },
      is_volatile => $volatile ? { true => 1, false => 0 },
      max_check_attempts => $max_failures,
      use => "base-service";
  }

  file {
    "$file":
      ensure => file,
      require => Nagios_service[$name],
      owner => nagios,
      mode => 644;
  }
}

class nagios::plugin::check_check {
  package {
    "nagios-manage":
      ensure => latest,
      provider => "gem";
  }

  nagios::command {
    "check_check":
      command => "/usr/bin/check_check.rb -s \$ARG1\$",
      remote => false; # this command runs on the nagios server
  }
}

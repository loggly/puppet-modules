define user::managed($ensure="present", $home="present", $root=false, $groups=["human"], $shell="/bin/bash") {
  include ::ssh::server
  include ::user::groups

  user {
    "$name":
      ensure => $ensure,
      shell => $shell,
      groups => $groups;
  }

  case $home {
    /^\//: { $_home = $home }
    "present": { $_home = "/home/$name" }
    default: { err("Invalid home directory for user $name: '$home'") }
  }

  if ($ensure == "present") {
    file {
      "$_home":
        ensure => directory,
        require => User[$name],
        owner => $name,
        group => "human",
        mode => 755;
    }

    if ($root) {
      User <| title == $name |> {
        groups +> ["sudo", "adm", "supervisorctl"]
      }
    }
  }

  file {
    "/etc/ssh/authorized-keys/$name.pub":
      ensure => $ensure,
      source => "puppet:///modules/user/publickeys/$name.pub",
      require => Class["ssh::server"];
  }
}

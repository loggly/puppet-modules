class iptables::enable {
  include iptables

  exec {
    "configure iptables":
      command => "build-iptables.rb | iptables-restore",
      require => Class["iptables"];
  }

  Iptables::Rule <| |> {
    before +> Exec["configure iptables"]
  }

}

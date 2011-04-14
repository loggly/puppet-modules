class user::groups {
  group {
    "sudo": ensure => present;
    "human": ensure => present;
    "supervisorctl": ensure => present;
  }
}

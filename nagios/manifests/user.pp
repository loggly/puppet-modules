class nagios::user {
  user {
    "nagios":
      groups => ["supervisorctl"];
  }
}

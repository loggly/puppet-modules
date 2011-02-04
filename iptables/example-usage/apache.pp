class apache {
  iptables::rule {
    "allow http/https from anywhere":
      ports => [ 80, 443 ],
      sources => [ "0.0.0.0/8" ];
  }
}

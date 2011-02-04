class apache {
  iptables::rule {
    "allow port 80 from anywhere":
      ports => [ 80, 443 ],
      sources => [ "0.0.0.0/8" ];
  }
}

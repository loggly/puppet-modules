class truth::enforcer {
  if has_role("proxy") {
    include ::loggly::proxy
  }

  if has_role("membase") {
    include ::membase
  }

  if has_role("zookeeper") {
    include ::loggly::zookeeper
  }
  
  if has_role("solr") {
    include ::loggly::solrserver
  }

  if has_role("buildserver") {
    include ::loggly::buildserver
  }

  if has_role("monitor") {
    include ::loggly::monitoring
  }

  if has_role("activemq") {
    include ::activemq
    include ::rabbitmq
  }

  if has_role("frontend") {
    include ::loggly::frontend
  }

  if has_role("mongodb") {
    include ::mongodb::server
  }

  if has_role("graphite") {
    include ::graphite::server
  }

  if extlookup("config/infrastructure/iptables-management") == "true" { include ::loggly::firewall
  }
}


class java::jdk {
  include ::java::jre

  debian::package { 
    "sun-java6-jdk":
      ensure => latest,
      config => "sun-java6-jdk   shared/accepted-sun-dlj-v1-1    boolean true",
      require => Class["java::jre"];
  }
}

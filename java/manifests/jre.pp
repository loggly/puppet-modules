class java::jre {
  debian::package { 
    "sun-java6-jre":
      ensure => latest,
      config => "sun-java6-jre   shared/accepted-sun-dlj-v1-1    boolean true",
      require => Package["sun-java6-bin"],
      notify => Exec["use sun java"];
    "sun-java6-bin":
      ensure => latest,
      config => "sun-java6-bin   shared/accepted-sun-dlj-v1-1    boolean true",
      notify => Exec["use sun java"];
  }

  exec {
    "use sun java":
      command => "update-alternatives --set java /usr/lib/jvm/java-6-sun/jre/bin/java",
      refreshonly => true;
  }
}

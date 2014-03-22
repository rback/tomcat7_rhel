class tomcat7_rhel::tomcat7_rhel {
  include tomcat7_rhel::devops_repo

  package { "java-1.7.0-openjdk":
    ensure => latest
  }
  package { "java-1.7.0-openjdk-devel":
    ensure => latest,
    require => Package["java-1.7.0-openjdk"]
  }
  package { "tomcat7":
    ensure => latest,
    require => [Package['java-1.7.0-openjdk']]
  }
  package { "tomcat7-manager":
    ensure => installed,
    require => [Package['tomcat7'], Yumrepo['devopskoulu']]
  }
}

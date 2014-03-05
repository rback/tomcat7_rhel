  include tomcat7_rhel::devops_repo
define tomcat7_rhel::tomcat7_rhel($openjdk_version, $openjdk_devel_version, $use_tomcat_native_apr) {
  require rpm_repositories::tomcat_rhel
  include tomcat7_rhel::packages

  if $use_tomcat_native_apr == 'true' {
    include tomcat7_rhel::apr
  }


}

class tomcat7_rhel::apr {
    package { "tomcat-native":
      ensure => "installed"
    }
}

class tomcat7_rhel::packages {
  package { "java-1.7.0-openjdk":
    ensure => $openjdk_version
  }
  package { "java-1.7.0-openjdk-devel":
    ensure => $openjdk_devel_version,
    require => Package["java-1.7.0-openjdk"]
  }
  package { "tomcat-wsp":
    ensure => installed,
    require => [Package['java-1.7.0-openjdk']]
  }  
}

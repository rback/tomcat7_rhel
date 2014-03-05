class tomcat7_rhel::tomcat7_manager_package {
  package { "tomcat-wsp-manager":
    ensure => installed,
    require => [Package['tomcat7'], Yumrepo['devopskoulu']]
  }
}

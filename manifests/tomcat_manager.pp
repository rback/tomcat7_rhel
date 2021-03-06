define tomcat7_rhel::tomcat_manager(
                                    $tomcat_admin_user,
                                    $tomcat_admin_password,
                                    $tomcat_user,
                                    $application_dir,
                                    $application_name,
                                    $tomcat_port) {
  require tomcat7_rhel::tomcat7_rhel

  file { "$application_dir/conf/Catalina/localhost/manager.xml":
    content => template("tomcat7_rhel/application/conf/manager.xml.erb"),
    before => Service["$application_name"]
  }

  file { "$application_dir/conf/tomcat-users.xml":
    content => template("tomcat7_rhel/application/conf/tomcat-users.xml.erb"),
    before => Service["$application_name"]
  }

  file { "$application_dir/bin/deploy_with_tomcat_manager.sh":
    content => template("tomcat7_rhel/application/bin/deploy_with_tomcat_manager.sh.erb"),
    owner   => "$tomcat_user",
    group   => "$tomcat_user",
    mode    => 0740,
    require => [File["$application_dir/bin"], Service["$application_name"]]
  }

  file { "$application_dir/bin/list-applications.sh":
    content => template("tomcat7_rhel/application/bin/list-applications.sh.erb"),
    owner   => "$tomcat_user",
    group   => "$tomcat_user",
    mode    => 0740,
    require => [File["$application_dir/bin"], Service["$application_name"]]
  }

  file { "$application_dir/bin/undeploy_with_tomcat_manager.sh":
    content => template("tomcat7_rhel/application/bin/undeploy_with_tomcat_manager.sh.erb"),
    owner   => "$tomcat_user",
    group   => "$tomcat_user",
    mode    => 0740,
    require => [File["$application_dir/bin"], Service["$application_name"]]
  }
}

define tomcat7_rhel::tomcat_application(
  $application_name = $title,
  $application_root,
  $tomcat_user,
  $tomcat_port,
  $tomcat_control_port = ($tomcat_port + 1000),
  $jvm_envs,
  $tomcat_manager = false,
  $tomcat_admin_user = "tomcat",
  $tomcat_admin_password = "s3cr3t",
  $server_xml_engine_config = "",
  $jmx_registry_port = 10052,
  $jmx_server_port = 10051,
  $smoke_test_path = "/",
  ) {

  include tomcat7_rhel::tomcat7_rhel

  $application_dir = "$application_root/$application_name"
  $catalina_out = "$application_dir/logs/catalina.out"
  $catalina_home = "/usr/share/tomcat7"

  file { [
    "$application_dir/bin","$application_dir/conf","$application_dir/temp",
    "$application_dir/work", "$application_dir/logs",
    "$application_dir/webapps", "$application_dir/conf/Catalina",
    "$application_dir/conf/Catalina/localhost"]:
    ensure => directory,
    owner => $tomcat_user,
    group => $tomcat_user,
    before => Service["$application_name"]
  }

  file { "$application_dir":
    ensure => directory,
  }

  tomcat7_rhel::tomcat_manager { "Install Tomcat Manager for $application_name":
    tomcat_admin_user => $tomcat_admin_user,
    tomcat_admin_password => $tomcat_admin_password,
    tomcat_user => $tomcat_user,
    application_dir => $application_dir,
    application_name => $application_name,
    tomcat_port => $tomcat_port
 }

  file { "/etc/init.d/$application_name":
    content => template("tomcat7_rhel/etc/init.d/application-initscript.erb"),
    mode => 0744,
    before => Service["$application_name"]
  }

  file { "/etc/sysconfig/$application_name":
    content => template("tomcat7_rhel/etc/sysconfig/application-sysconfig.erb"),
    mode => 0744,
    before => Service["$application_name"]
  }

  service { "$application_name":
    ensure => running,
    enable => true,
  }

  file { "$application_dir/conf/web.xml":
    ensure => link,
    target => "$catalina_home/conf/web.xml",
    before => Service["$application_name"]
  }

  file { "$application_dir/bin/setenv.sh":
    content => template("tomcat7_rhel/application/bin/setenv.sh.erb"),
    before => Service["$application_name"]
  }

  file { "$application_dir/conf/server.xml":
    content => template("tomcat7_rhel/application/conf/server.xml.erb"),
    before => Service["$application_name"]
  }

  file { "/etc/logrotate.d/$application_name":
    content => template("tomcat7_rhel/etc/logrotate.d/application-logrotate.erb"),
    before => Service["$application_name"]
  }

  file { "$application_dir/bin/run_smoke_test.sh":
    content => template("tomcat7_rhel/application/bin/run_smoke_test.sh.erb"),
    owner   => "$tomcat_user",
    group   => "$tomcat_user",
    mode    => 0744,
    require => File["$application_dir/bin"],
    before => Service["$application_name"]
  }
}

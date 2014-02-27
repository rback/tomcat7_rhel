class tomcat7_rhel::devops_repo {
  yumrepo { "devopskoulu":
    descr => "Devops repository",
    baseurl => "http://download.reaktor.fi/devopskoulu/repo",
    enabled => 1,
    gpgcheck => 0,
  }
}

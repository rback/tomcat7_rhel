# Tomcat 7 on RHEL 6
[![Build Status](http://spode.saunalahti.fi/buildStatus/icon?job=tomcat7_rhel)](http://spode.saunalahti.fi/view/common/job/tomcat7_rhel/)

## Features

* Deploy multiple Tomcat instances on same machine ("the base + home setup")
* Use Tomcat Manager for deployment
* Use JMX for monitoring the Tomcat instances
* Use a ready-made smoke test script to test whether your web application is up and running

## Example usage

### Configure Puppet

    # In site.pp
    node "superserver" {
      tomcat7_rhel::tomcat_application { "my-web-application":
        application_root => "/opt",
        tomcat_user => "webuser",
        tomcat_port => "8080",
        jvm_envs => "-server -Xmx1024m -Xms128m -XX:MaxPermSize=256m -Dmy.java.opt=i_love_java -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=some.ip.address",
        tomcat_manager => true,
        tomcat_admin_user => "superuser",
        tomcat_admin_password => "secretpassword",
        smoke_test_path => "/health-check"
        jmx_registry_port => 10054,
        jmx_server_port => 10053
      }

      tomcat7_rhel::tomcat_application { "my-second-application":
        application_root => "/opt",
        tomcat_user => "webuser",
        tomcat_port => "8090",
        disable_access_log => true,
        jvm_envs => "-server -Xmx1024m -Xms128m -XX:MaxPermSize=256m -Dmy.java.opt=i_love_scala -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=some.ip.address"
      }
    }

### Adding extra configuration into the `<Engine>` tag of `server.xml`

You can include additional configuration in the `<Engine>` tag of you
`server.xml` by including a valid
[engine](http://tomcat.apache.org/tomcat-7.0-doc/config/engine.html) value in
the `server_xml_engine_config` parameter of `tomcat7_rhel::tomcat_application`.

For example, you can enable Tomcat 7 session replication with the help of the
`server_xml_engine_config` parameter. See the example below for more info.

#### Enabling session replication

Take a look at [Tomcat 7 Clustering/Session Replication HOW-TO](http://tomcat.apache.org/tomcat-7.0-doc/cluster-howto.html).

Enable default clustering by passing `server_xml_engine_config` into `tomcat7_rhel::tomcat_application`:

    server_xml_engine_config => "<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"/>"

Full control over the clustering xml fragment can be done conveniently by using your own template:

	server_xml_engine_config => template("mymodule/my_tomcat_cluster_config.erb")

### Deploy


    scp app.war webuser@superserver:/tmp/app.war
    ssh webuser@superserver "/opt/my-web-application/bin/deploy_with_tomcat_manager.sh /tmp/app.war"

Note that if you deploy with Manager, make sure your application shuts down correctly when Tomcat calls the
`ServletContextListener#contextDestroyed` method, otherwise you will eventually experience out-of-memory errors.

You can use the `check_memory_leaks.sh` to find memory leaks. It's under the
`bin` directory of your web application.

#####  You can also use the parallel deployment feature of Tomcat (http://tomcat.apache.org/tomcat-7.0-doc/config/context.html#Parallel_deployment)

    scp app.war webuser@superserver:/tmp/app.war
    ssh webuser@superserver "/opt/my-web-application/bin/deploy_with_tomcat_manager.sh /tmp/app.war 1.2"

The above example starts a new version (1.2) of application in the same context path as the old one, without shutting down the old version,
meaning that new sessions (and requests) will go to the new instance, while existing sessions stay in the old version of application.
This results in zero downtime for your application.

You can list the running applications and their versions:

	ssh webuser@superserver "/opt/my-web-application/bin/list-applications.sh"

And undeploy an old version of the application:

	ssh webuser@superserver "/opt/my-web-application/bin/undeploy_with_tomcat_manager.sh 1.1"

### Run smoke test on the application

    ssh webuser@superserver "/opt/my-web-application/bin/run_smoke_test.sh"

### JMX monitoring

* Following JMX keys might be of intereset:

		jmx["Catalina:type=ThreadPool,name=\"http-apr-8080\"",maxThreads]
		jmx["Catalina:type=ThreadPool,name=\"http-apr-8080\"",currentThreadsBusy]
		jmx["Catalina:type=ThreadPool,name=\"http-apr-8080\"",currentThreadCount]
		jmx["Catalina:type=GlobalRequestProcessor,name=\"http-apr-8080\"",requestCount]

		You need to replace http-apr-8080 with port (8080) and engine (apr, bio, nio) that you use.

* You could also monitor sessions:

		jmx["Catalina:type=Manager,context=/,host=localhost",maxActiveSessions]
		jmx["Catalina:type=Manager,context=/,host=localhost",activeSessions]
		jmx["Catalina:type=Manager,context=/,host=localhost",maxActive]

		Problems rise if parallel deployment is used, because context will then be
		something like context=/##1.2.3, which will change during every deploy

## Temp files

To automatically delete the Tomcat temp files, add the parameter
`auto_delete_tomcat_temp_files = true` into the
`tomcat7_rhel::tomcat_application` call.

## Development

### Versioning

This project uses [Semantic Versioning](http://semver.org).

### Tests

    bundle install
    rake

## Links

This project is forked from <https://github.com/laurilehmijoki/tomcat7_rhel>.

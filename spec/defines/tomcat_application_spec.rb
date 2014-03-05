require 'spec_helper'

describe 'tomcat7_rhel::tomcat_application' do
  let(:title) { 'my-webapp' }

  let(:default_params) {{
    :application_root => '/opt/server',
    :tomcat_user      => 'tomcat',
    :tomcat_port      => 8080,
    :jvm_envs         => '-Dfoo=bar'
  }}

  describe 'java' do
    let(:params) { default_params }

    it { should contain_package("java-1.7.0-openjdk") }
    it { should contain_package("java-1.7.0-openjdk-devel") }
  end

  describe 'tomcat package' do
    let(:params) { default_params }

    it {
      should contain_package('tomcat-wsp').with({
        'ensure' => 'installed'
      })
    }
  end

  describe 'auto_delete_tomcat_temp_files' do
    let(:params) {
      default_params.merge({
        :auto_delete_tomcat_temp_files => true
      })
    }

    it {
      should contain_file('/etc/cron.hourly/auto_delete_tomcat_temp_files-my-webapp.rb').with({
        :mode => '0744'
      })
    }

    it {
      should contain_file('/etc/cron.hourly/auto_delete_tomcat_temp_files-my-webapp.rb')
        .with_content(/.*catalina.pid.*/) # It should not delete the catalina.pid file
    }
  end

  describe 'installing tomcat manager' do
    let(:params) {
      default_params.merge({
        :tomcat_manager => true
      })
    }

    it {
      should contain_package('tomcat-wsp-manager').with({
        'ensure' => 'installed'
      })
    }
  end
end

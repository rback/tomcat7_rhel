require 'spec_helper'

describe 'tomcat7_rhel::tomcat7_rhel' do
  let(:title) { '' }

  let(:params) {{
    :openjdk_version => '1.7',
    :openjdk_devel_version => '1.7',
    :use_tomcat_native_apr => false
  }}

  it { should contain_class('rpm_repositories::tomcat_rhel') }
end

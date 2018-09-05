require 'spec_helper'

describe 'nrpe::plugin', :type => 'define' do

  let :title do 'foo' end
  on_supported_os.each do |os, facts|

    context "on platform #{os} with no args" do
      let :facts do
        facts
      end
      it { should_not compile }


      context 'with too many args set' do
          let :params do {
            :content => 'foo bar baz',
            :source  => 'puppet:///modules/nrpe/plugins/check_3ware.sh'
          } end
        it { should raise_error(Puppet::Error, /Cannot set /) }
      end

      [ { :content => 'foo bar baz'                                   },
        { :source  => 'puppet:///modules/nrpe/plugins/check_3ware.sh' },
      ].each do |params|
        context "with #{params.keys[0]} set" do
          let :params do params end

          case facts[:osfamily]
          when 'RedHat'  then
            it { should contain_file('foo').with_path('/usr/lib64/nagios/plugins/foo') }
          when 'Darwin'  then
            it { should contain_file('foo').with_path('/opt/local/libexec/nagios/foo') }
          when 'Debian'  then
            it { should contain_file('foo').with_path('/usr/lib/nagios/plugins/foo') }
          when 'FreeBSD' then
            it { should contain_file('foo').with_path('/usr/local/libexec/nagios/foo') }
          when 'Solaris' then
            it { should contain_file('foo').with_path('/opt/csw/libexec/nagios-plugins/foo') }
          end
        end
      end
    end
  end
end

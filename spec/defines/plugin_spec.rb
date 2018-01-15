require 'spec_helper'

describe 'nrpe::plugin', :type => 'define' do

  let :title do 'foo' end

  [ { :osfamily => 'RedHat' , :kernel => 'Linux',   :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '7.4.1708',     },
    { :osfamily => 'Debian' , :kernel => 'Linux',   :architecture => 'amd64' , :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '16.04',        },
    { :osfamily => 'FreeBSD', :kernel => 'FreeBSD', :architecture => 'amd64' , :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '10.3-RELEASE', },
    { :osfamily => 'Darwin' , :kernel => 'Darwin',  :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '17.3.0',       },
    { :osfamily => 'Solaris', :kernel => 'SunOS',   :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '10',           },
  ].each do |myfacts|
    context myfacts[:osfamily] do
      let :facts do myfacts end

      context "on platform #{myfacts[:osfamily]} with no args" do
        it { should_not compile }
      end

      context "on platform #{myfacts[:osfamily]} with too many args set" do
          let :params do {
            :content => 'foo bar baz',
            :source  => 'puppet:///modules/nrpe/plugins/check_3ware.sh'
          } end
        it { should raise_error(Puppet::Error, /Cannot set /) }
      end

      [ { :content => 'foo bar baz'                                   },
        { :source  => 'puppet:///modules/nrpe/plugins/check_3ware.sh' },
      ].each do |params|
        context "on platform #{myfacts[:osfamily]} with #{params.keys[0]} set" do
          let :params do params end

          case myfacts[:osfamily]
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

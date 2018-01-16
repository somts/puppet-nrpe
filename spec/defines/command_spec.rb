require 'spec_helper'

describe 'nrpe::command', :type => 'define' do

  let :title do 'foo' end

  [ { :osfamily => 'RedHat' , :kernel => 'Linux',   :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '7.4.1708',     },
    { :osfamily => 'Debian' , :kernel => 'Linux',   :architecture => 'amd64' , :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '16.04', :operatingsystemmajrelease => '16.04', },
    { :osfamily => 'FreeBSD', :kernel => 'FreeBSD', :architecture => 'amd64' , :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '10.3-RELEASE', },
    { :osfamily => 'Darwin' , :kernel => 'Darwin',  :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '17.3.0',       },
    { :osfamily => 'Solaris', :kernel => 'SunOS',   :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '10',           },
  ].each do |myfacts|
    context myfacts[:osfamily] do
      let :facts do myfacts end

      context "on platform #{myfacts[:osfamily]} with no args" do
        it { should_not compile }
      end

      context "on platform #{myfacts[:osfamily]} with command arg" do
        let :params do { :command => 'foo bar baz' } end

        case myfacts[:osfamily]
        when 'RedHat'  then
          it { should contain_file('/etc/nagios/nrpe.d/command-foo.cfg').with_content(
            /command\[foo\]=\/usr\/lib64\/nagios\/plugins\/foo bar baz/
          ) }
        when 'Darwin'  then
          it { should contain_file('/opt/local/etc/nrpe/nrpe.d/command-foo.cfg').with_content(
            /command\[foo\]=\/opt\/local\/libexec\/nagios\/foo bar baz/
          ) }
        when 'Debian'  then
          it { should contain_file('/etc/nagios/nrpe.d/command-foo.cfg').with_content(
            /command\[foo\]=\/usr\/lib\/nagios\/plugins\/foo bar baz/
          ) }
        when 'FreeBSD' then
          it { should contain_file('/usr/local/etc/nrpe.d/command-foo.cfg').with_content(
            /command\[foo\]=\/usr\/local\/libexec\/nagios\/foo bar baz/
          ) }
        when 'Solaris' then
          it { should contain_file('/etc/opt/csw/nrpe.d/command-foo.cfg').with_content(
            /command\[foo\]=\/opt\/csw\/libexec\/nagios-plugins\/foo bar baz/
          ) }
        end
      end
    end
  end
end

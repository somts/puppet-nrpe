require 'spec_helper'

describe 'nrpe::command', :type => 'define' do

  let :title do 'foo' end

  on_supported_os.each do |os, os_facts|

    context "on platform #{os} with no args" do
      let :facts do
        os_facts
      end
      it { should_not compile }

      context 'with command arg' do
        let :params do { :command => 'foo bar baz' } end

        case os_facts[:osfamily]
        when 'Debian' then
          it do
            should contain_file('/etc/nagios/nrpe.d/command-foo.cfg').with_content(
              /command\[foo\]=\/usr\/lib\/nagios\/plugins\/foo bar baz/
            )
          end
        when 'RedHat' then
          it do
            should contain_file('/etc/nagios/nrpe.d/command-foo.cfg').with_content(
              /command\[foo\]=\/usr\/lib64\/nagios\/plugins\/foo bar baz/
            )
          end
        when 'Darwin'  then
          it do
            should contain_file('/opt/local/etc/nrpe/nrpe.d/command-foo.cfg').with_content(
              /command\[foo\]=\/opt\/local\/libexec\/nagios\/foo bar baz/
            )
          end
        when 'FreeBSD' then
          it do
            should contain_file('/usr/local/etc/nrpe.d/command-foo.cfg').with_content(
              /command\[foo\]=\/usr\/local\/libexec\/nagios\/foo bar baz/
            )
          end
        end
      end
    end
  end
end

require 'spec_helper'

describe 'nrpe::command', :type => 'define' do
  let :title do
    'foo'
  end

  on_supported_os.each do |os, os_facts|
    context "on platform #{os} with no args" do
      let :facts do
        os_facts
      end

      it do is_expected.not_to compile end

      context 'with command arg' do
        let :params do
          { command: 'foo bar baz' }
        end

        it do is_expected.to compile.with_all_deps end

        case os_facts[:osfamily]
        when 'Darwin'
          it do
            is_expected.to contain_file(
              '/opt/local/etc/nrpe/nrpe.d/command-foo.cfg',
            ).with_content(
              %r{command\[foo\]=\/opt\/local\/libexec\/nagios\/foo bar baz},
            )
          end
        when 'Debian'
          it do
            is_expected.to contain_file(
              '/etc/nagios/nrpe.d/command-foo.cfg',
            ).with_content(
              %r{command\[foo\]=\/usr\/lib\/nagios\/plugins\/foo bar baz},
            )
          end
        when 'FreeBSD'
          it do
            is_expected.to contain_file(
              '/usr/local/etc/nrpe.d/command-foo.cfg',
            ).with_content(
              %r{command\[foo\]=\/usr\/local\/libexec\/nagios\/foo bar baz},
            )
          end
        when 'RedHat'
          it do
            is_expected.to contain_file(
              '/etc/nagios/nrpe.d/command-foo.cfg',
            ).with_content(
              %r{command\[foo\]=\/usr\/lib64\/nagios\/plugins\/foo bar baz},
            )
          end
        end
      end
    end
  end
end

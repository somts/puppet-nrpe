require 'spec_helper'

describe 'nrpe::plugin', type: 'define' do
  let :title do
    'foo'
  end

  on_supported_os.each do |os, os_facts|
    context "on platform #{os} with no args" do
      let :facts do
        os_facts
      end

      it { is_expected.not_to compile }

      context 'with too many args set' do
        let :params do
          {
            content: 'foo bar baz',
            source: 'puppet:///modules/nrpe/plugins/check_3ware.sh',
          }
        end

        it do
          is_expected.to raise_error(Puppet::Error, %r{Cannot set })
        end
      end

      [ { source: 'puppet:///modules/nrpe/plugins/check_3ware.sh' },
        { content: 'foo bar baz' } ].each do |params|
        context "with #{params.keys[0]} set" do
          let :params do
            params
          end

          it do is_expected.to compile.with_all_deps end

          case os_facts[:osfamily]
          when 'Darwin'  then
            it do
              is_expected.to contain_file('foo').with_path(
                '/opt/local/libexec/nagios/foo',
              )
            end
          when 'Debian'  then
            it do
              is_expected.to contain_file('foo').with_path(
                '/usr/lib/nagios/plugins/foo',
              )
            end
          when 'FreeBSD' then
            it do
              is_expected.to contain_file('foo').with_path(
                '/usr/local/libexec/nagios/foo',
              )
            end
          when 'RedHat'  then
            it do
              is_expected.to contain_file('foo').with_path(
                '/usr/lib64/nagios/plugins/foo',
              )
            end
          when 'Solaris' then
            it do
              is_expected.to contain_file('foo').with_path(
                '/opt/csw/libexec/nagios-plugins/foo',
              )
            end
          end
        end
      end
    end
  end
end

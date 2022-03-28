require 'spec_helper'
describe 'nrpe' do
  shared_examples 'with default values for all parameters' do
    it do is_expected.to compile.with_all_deps end
    it do is_expected.to contain_class('nrpe') end
    it do
      is_expected.to contain_class(
        'nrpe::install',
      ).that_comes_before('Class[nrpe::config]')
    end
    it do
      is_expected.to contain_class(
        'nrpe::config',
      ).that_notifies('Class[nrpe::service]')
    end
    it do is_expected.to contain_class('nrpe::config::ntp') end
    it do is_expected.to contain_class('nrpe::service') end

    it do is_expected.to contain_package('nrpe').with_ensure('present') end
    it do is_expected.to contain_file('nrpe.d').with_ensure('directory') end

    it do
      is_expected.to contain_file('nrpe.cfg').with(
        ensure: 'present',
        content: %r{^# Managed by Puppet nrpe\.\n},
      ).that_notifies('Service[nrpe]')
    end

    it do
      is_expected.to contain_service('nrpe').with(ensure: 'running', enable: true)
    end
    it do is_expected.to contain_nrpe__plugin('check_myfilesize') end
    it do is_expected.to contain_nrpe__command('check_myfilesize') end

    context 'set to absent' do
      let :params do
        { ensure: 'absent' }
      end

      it do
        is_expected.to contain_service('nrpe').with(ensure: 'stopped', enable: false)
      end
      it do is_expected.to contain_file('nrpe.cfg').with_ensure('absent') end
      it do is_expected.to contain_file('nrpe.d').with_ensure('absent') end
      it do is_expected.to contain_package('nrpe').with_ensure('absent') end
    end
  end

  shared_examples 'Darwin' do
    it do is_expected.not_to contain_class('nrpe::config::log') end
    it do is_expected.to contain_package('nagios-plugins') end
    it do is_expected.to contain_service('nrpe').with_name('org.macports.nrpe') end
    it do
      is_expected.to contain_file('nrpe.d').with_path('/opt/local/etc/nrpe/nrpe.d')
    end
    it do
      is_expected.to contain_file('nrpe.cfg').with_path('/opt/local/etc/nrpe/nrpe.cfg')
    end
    it do is_expected.to contain_file('/private/etc/nrpe.cfg').with_ensure('link') end

    it_behaves_like 'no zfs plugin'
    context 'set to absent' do
      let :params do
        { ensure: 'absent' }
      end

      it do
        is_expected.to contain_file('/private/etc/nrpe.cfg').with_ensure('absent')
      end
    end
  end

  shared_examples 'Debian' do
    it do is_expected.to contain_package('nagios-plugins') end
    it do is_expected.to contain_service('nrpe').with_name('nagios-nrpe-server') end
    it do is_expected.to contain_file('nrpe.d').with_path('/etc/nagios/nrpe.d') end
    it do is_expected.to contain_file('nrpe.cfg').with_path('/etc/nagios/nrpe.cfg') end
    it do is_expected.to contain_file('/etc/nrpe.cfg').with_ensure('link') end

    it_behaves_like 'no zfs plugin'
    it_behaves_like 'removing convenience symlink'
    it_behaves_like 'Linux'
  end

  shared_examples 'FreeBSD' do
    it do is_expected.to contain_class('nrpe::config::log') end
    it do is_expected.to contain_package('nagios-plugins') end
    it do is_expected.to contain_service('nrpe').with_name('nrpe3') end
    it do is_expected.to contain_file('nrpe.d').with_path('/usr/local/etc/nrpe.d') end
    it do
      is_expected.to contain_file('nrpe.cfg').with_path('/usr/local/etc/nrpe.cfg')
    end
    it do is_expected.not_to contain_file('/etc/nrpe.cfg').with_ensure('link') end

    it_behaves_like 'no zfs plugin'

    context 'with zfs plugins enabled' do
      let :params do
        { manage_checkzfs: true }
      end

      it_behaves_like 'zfs plugin without sudo'
    end
  end

  shared_examples 'RedHat' do
    it do is_expected.to contain_package('nagios-plugins-all') end
    it do is_expected.to contain_service('nrpe').with_name('nrpe') end
    it do is_expected.to contain_file('nrpe.d').with_path('/etc/nagios/nrpe.d') end
    it do is_expected.to contain_file('nrpe.cfg').with_path('/etc/nagios/nrpe.cfg') end
    it do is_expected.to contain_file('/etc/nrpe.cfg').with_ensure('link') end

    it_behaves_like 'no zfs plugin'
    it_behaves_like 'removing convenience symlink'
    it_behaves_like 'Linux'

    context 'with zfs plugins enabled' do
      let :params do
        { manage_checkzfs: true }
      end

      it_behaves_like 'zfs plugin with sudo'
    end
  end

  shared_examples 'Linux' do
    it do is_expected.to contain_class('nrpe::config::firewall') end
    it do is_expected.to contain_class('nrpe::config::log') end
    it do
      is_expected.to contain_nrpe__plugin('check_open_files').with_ensure('present')
    end
    it do
      is_expected.to contain_nrpe__command('check_open_files').with(
        ensure: 'present',
        use_sudo: false,
      )
    end

    it do
      is_expected.not_to contain_firewall('200 IPv4 NRPE 127.0.0.1').with(
        action: 'accept',
        proto: 'tcp',
        source: '127.0.0.1',
        dport: 5666,
      )
    end

    context 'more allowed_hosts' do
      let :params do
        { allowed_hosts: ['127.0.0.1', '192.168.0.1'] }
      end

      it do
        is_expected.not_to contain_firewall('200 IPv4 NRPE 127.0.0.1').with(
          action: 'accept',
          proto: 'tcp',
          source: '127.0.0.1',
          dport: 5666,
        )
      end
      it do
        is_expected.to contain_firewall('200 IPv4 NRPE 192.168.0.1').with(
          action: 'accept',
          proto: 'tcp',
          source: '192.168.0.1',
          dport: 5666,
        )
      end
    end
  end

  shared_context 'removing convenience symlink' do
    let :params do
      { ensure: 'absent' }
    end

    it do is_expected.to contain_file('/etc/nrpe.cfg').with_ensure('absent') end
  end

  shared_examples 'zfs plugin without sudo' do
    it do is_expected.to contain_nrpe__plugin('check_zfs').with_ensure('present') end
    it do
      is_expected.to contain_nrpe__command(
        'check_zfs'
      ).with(ensure: 'present', use_sudo: false)
    end
    it do is_expected.not_to contain_sudo__conf('nrpe-allow-check_zfs') end
  end

  shared_examples 'zfs plugin with sudo' do
    it do is_expected.to contain_nrpe__plugin('check_zfs').with_ensure('present') end
    it do
      is_expected.to contain_nrpe__command(
        'check_zfs',
      ).with(ensure: 'present', use_sudo: true)
    end
    it do is_expected.to contain_sudo__conf('nrpe-allow-check_zfs') end
  end

  shared_examples 'no zfs plugin' do
    it do
      is_expected.not_to contain_nrpe__plugin('check_zfs').with_ensure('present')
    end
    it do
      is_expected.not_to contain_nrpe__command('check_zfs').with_ensure('present')
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      it do is_expected.to compile.with_all_deps end
      it do is_expected.to create_class('nrpe') end
      it do
        is_expected.to create_class('nrpe::install').that_comes_before(
          'Class[nrpe::config]',
        )
      end
      it do
        is_expected.to create_class('nrpe::config').that_notifies(
          'Class[nrpe::service]',
        )
      end
      it do is_expected.to create_class('nrpe::service') end

      case os_facts[:osfamily]
      when 'Darwin' then
        it_behaves_like 'Darwin'
      when 'Debian' then
        it_behaves_like 'Debian'
      when 'FreeBSD' then
        it_behaves_like 'FreeBSD'
      when 'RedHat' then
        it_behaves_like 'RedHat'
      end
    end
  end
end

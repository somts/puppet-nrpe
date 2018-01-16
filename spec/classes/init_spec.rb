require 'spec_helper'
describe 'nrpe' do

  shared_context 'with default values for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('nrpe') }
    it { should contain_class('nrpe::install').that_comes_before('Class[nrpe::config]') }
    it { should contain_class('nrpe::config').that_notifies('Class[nrpe::service]') }
    it { should contain_class('nrpe::config::ntp') }
    it { should contain_class('nrpe::service') }

    it { should contain_package('nrpe').with_ensure('present') }
    it { should contain_file('nrpe.d').with({ :ensure => 'directory' })}

    it { should contain_file('nrpe.cfg').with({
      :ensure  => 'present',
      :content => /^# Managed by Puppet nrpe\.\n/,
    }).that_notifies('Service[nrpe]') }

    it { should contain_service('nrpe').with({
      :ensure => 'running',
      :enable => true,
    }) }
    it { should contain_nrpe__plugin('check_myfilesize') }
    it { should contain_nrpe__command('check_myfilesize') }

    context 'set to absent' do
      let :params do { :ensure => 'absent' } end
      it { should contain_service('nrpe').with({
        :ensure => 'stopped',
        :enable => false,
      })}
      it { should contain_file('nrpe.cfg').with_ensure('absent') }
      it { should contain_file('nrpe.d').with_ensure('absent') }
      it { should contain_package('nrpe').with_ensure('absent') }
    end
  end

  shared_examples 'Darwin' do
    it { should_not contain_class('nrpe::config::log') }
    it { should contain_package('nagios-plugins') }
    it { should contain_service('nrpe').with_name('org.macports.nrpe') }
    it { should contain_file('nrpe.d').with_path('/opt/local/etc/nrpe/nrpe.d') }
    it { should contain_file('nrpe.cfg').with_path('/opt/local/etc/nrpe/nrpe.cfg') }
    it { should contain_file('/private/etc/nrpe.cfg').with_ensure('link') }

    it_behaves_like 'no zfs plugin'
    context 'set to absent' do
      let :params do { :ensure => 'absent' } end
      it { should contain_file('/private/etc/nrpe.cfg').with_ensure('absent') }
    end
  end

  shared_examples 'Debian' do
    it { should contain_package('nagios-plugins') }
    it { should contain_service('nrpe').with_name('nagios-nrpe-server') }
    it { should contain_file('nrpe.d').with_path('/etc/nagios/nrpe.d') }
    it { should contain_file('nrpe.cfg').with_path('/etc/nagios/nrpe.cfg') }
    it { should contain_file('/etc/nrpe.cfg').with_ensure('link') }

    it_behaves_like 'no zfs plugin'
    it_behaves_like 'removing convenience symlink'
    it_behaves_like 'Linux'
  end

  shared_examples 'FreeBSD' do
    it { should contain_class('nrpe::config::log') }
    it { should contain_package('nagios-plugins') }
    it { should contain_service('nrpe').with_name('nrpe2') }
    it { should contain_file('nrpe.d').with_path('/usr/local/etc/nrpe.d') }
    it { should contain_file('nrpe.cfg').with_path('/usr/local/etc/nrpe.cfg') }
    it { should_not contain_file('/etc/nrpe.cfg').with_ensure('link') }

    it_behaves_like 'no zfs plugin'

    context 'with zfs plugins enabled' do
      let :params do { :zfs => true } end
      it_behaves_like 'zfs plugin without sudo'
    end
  end

  shared_examples 'RedHat' do
    it { should contain_package('nagios-plugins-all') }
    it { should contain_service('nrpe').with_name('nrpe') }
    it { should contain_file('nrpe.d').with_path('/etc/nagios/nrpe.d') }
    it { should contain_file('nrpe.cfg').with_path('/etc/nagios/nrpe.cfg') }
    it { should contain_file('/etc/nrpe.cfg').with_ensure('link') }

    it_behaves_like 'no zfs plugin'
    it_behaves_like 'removing convenience symlink'
    it_behaves_like 'Linux'

    context 'with zfs plugins enabled' do
      let :params do { :zfs => true } end
      it_behaves_like 'zfs plugin with sudo'
    end
  end

  shared_examples 'Solaris' do
    it { should_not contain_class('nrpe::config::log') }
    it { should contain_package('nagios_plugins') }
    it { should contain_service('nrpe').with_name('svc:/network/cswnrpe:default') }
    it { should contain_file('nrpe.d').with_path('/etc/opt/csw/nrpe.d') }
    it { should contain_file('nrpe.cfg').with_path('/etc/opt/csw/nrpe.cfg') }
    it { should contain_file('/etc/nrpe.cfg').with_ensure('link') }

    it_behaves_like 'no zfs plugin'
    it_behaves_like 'removing convenience symlink'

    context 'with zfs plugins enabled' do
      let :params do { :zfs => true } end
      it_behaves_like 'zfs plugin without sudo'
    end
  end

  shared_examples 'Linux' do
    it { should contain_class('nrpe::config::firewall') }
    it { should contain_class('nrpe::config::log') }
    it { should contain_nrpe__plugin('check_open_files').with_ensure('present') }
    it { should contain_nrpe__command('check_open_files').with({
      :ensure   => 'present',
      :use_sudo => false,
    } ) }

    it { should_not contain_firewall('200 NRPE 127.0.0.1').with({
      :action => 'accept',
      :proto  => 'tcp',
      :source => '127.0.0.1',
      :dport  => 5666,
    }) }

    context 'more allowed_hosts' do
      let :params do { :allowed_hosts => ['127.0.0.1','192.168.0.1'] } end

    it { should_not contain_firewall('200 NRPE 127.0.0.1').with({
        :action => 'accept',
        :proto  => 'tcp',
        :source => '127.0.0.1',
        :dport  => 5666,
      }) }
      it { should contain_firewall('200 NRPE 192.168.0.1').with({
        :action => 'accept',
        :proto  => 'tcp',
        :source => '192.168.0.1',
        :dport  => 5666,
      }) }
    end
  end

  shared_context 'removing convenience symlink' do
    let :params do { :ensure => 'absent' } end
    it { should contain_file('/etc/nrpe.cfg').with_ensure('absent') }
  end

  shared_examples 'zfs plugin without sudo' do
    it { should contain_nrpe__plugin('check_zfs').with_ensure('present') }
    it { should contain_nrpe__command('check_zfs').with({
      :ensure   => 'present',
      :use_sudo => false,
    } ) }
    it { should_not contain_sudo__conf('nrpe-allow-check_zfs') }
  end

  shared_examples 'zfs plugin with sudo' do
    it { should contain_nrpe__plugin('check_zfs').with_ensure('present') }
    it { should contain_nrpe__command('check_zfs').with({
      :ensure   => 'present',
      :use_sudo => true,
    } ) }
    it { should contain_sudo__conf('nrpe-allow-check_zfs') }
  end

  shared_examples 'no zfs plugin' do
    it { should_not contain_nrpe__plugin('check_zfs').with_ensure('present') }
    it { should_not contain_nrpe__command('check_zfs').with_ensure('present') }
  end

  [ { :osfamily => 'RedHat' , :kernel => 'Linux',   :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '7.4.1708',     },
    { :osfamily => 'Debian' , :kernel => 'Linux',   :architecture => 'amd64' , :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '16.04', :operatingsystemmajrelease => '16.04', },
    { :osfamily => 'FreeBSD', :kernel => 'FreeBSD', :architecture => 'amd64' , :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '10.3-RELEASE', },
    { :osfamily => 'Darwin' , :kernel => 'Darwin',  :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '17.3.0',       },
    { :osfamily => 'Solaris', :kernel => 'SunOS',   :architecture => 'x86_64', :sudoversion => '1.7.2p1', :puppetversion => '4.10.5', :operatingsystemrelease => '10',           },
  ].each do |myfacts|
    context myfacts[:osfamily] do
      let :facts do myfacts end
      it_behaves_like 'with default values for all parameters'

      case myfacts[:osfamily]
      when 'RedHat'  then it_behaves_like 'RedHat'
      when 'Darwin'  then it_behaves_like 'Darwin'
      when 'Debian'  then it_behaves_like 'Debian'
      when 'FreeBSD' then it_behaves_like 'FreeBSD'
      when 'Solaris' then it_behaves_like 'Solaris'
      end
    end
  end
end

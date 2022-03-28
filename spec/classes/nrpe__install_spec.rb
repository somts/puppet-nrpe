require 'spec_helper'

describe 'nrpe::install' do
  let :node do
    'example.com'
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} " do
      let :facts do
        os_facts
      end

      context 'with all defaults' do
        it do
          is_expected.to compile.and_raise_error(
            %r{Must only be called by nrpe},
          )
        end
      end
    end
  end
end

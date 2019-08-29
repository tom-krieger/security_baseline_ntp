require 'spec_helper'

describe 'security_baseline_ntp' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'enforce' => true,
          'message' => 'selinux',
          'loglevel' => 'warning',
          'config_data' => {
            'ntp_daemon' => 'ntp',
            'ntp_servers'=> ['0.de.pool.ntp.org', '1.de.pool.ntp.org'],
            'ntp_restrict' => [
              '-4 default kod nomodify notrap nopeer noquery',
              '-6 default kod nomodify notrap nopeer noquery',
            ],
          }
        } 
      end

      it { is_expected.to compile }
      it { is_expected.to contain_class('ntp') }
    end
  end
end

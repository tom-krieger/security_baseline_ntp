# frozen_string_literal: true

# ntp_service.rb
# Check which ntp serfice is running

Facter.add('ntp_daemon') do
  confine :osfamily => 'RedHat'
  setcode do
    chronyd = Facter::Core::Execution.exec('systemctl is-active chronyd')
    ntpd = Facter::Core::Execution.exec('systemctl is-active ntpd')
    
    if chronyd.empty? and ntpd.empty? then
      'none'
    elsif chronyd == 'active' then
      'chronyd'
    elsif ntpd == 'active' then
      'ntpd'
    else
      'unknown'
    end
  end
end
  
# @summary 
#     Ensure ntp is configured (Scored)
#
# ntp is a daemon which implements the Network Time Protocol (NTP). It is designed to synchronize system clocks across 
# a variety of systems and use a source that is highly accurate. More information on NTP can be found at http://www.ntp.org. 
# ntp can be configured to be a client and/or a server.
# This recommendation only applies if ntp is in use on the system.
#
# Rationale:
# If ntp is in use on the system proper configuration is vital to ensuring time synchronization is working properly.
# 
# @param enforce
#    Enforce the rule or just test and log
#
# @param message
#    Message to print into the log
#
# @param loglevel
#    The loglevel for the above message
#
# @param config_data
#    Hash with additional configuration data
#
# @example
#   class security_baseline_ntp {
#       enforce => true,
#       message => 'Test',
#       loglevel => 'info',
#       config_data => {
#         ntp_daemon => 'ntp',  
#         ntp_servers => ['server1', 'server2'],
#       }
#   }
#
class security_baseline_ntp (
  Boolean $enforce    = true,
  String $message     = '',
  String $loglevel    = '',
  String $logfile     = '',
  String $ntp_daemon  = '',
  Array $ntp_servers  = [],
  Array $ntp_restrict = [],
) {

  if $enforce {

    if(($ntp_daemon != 'none') and ($ntp_daemon != 'ntp') and ($ntp_daemon != 'chrony')) {
      fail("Invalid value ${ntp_daemon} for ntp daemon to configure.")
    }

    if($ntp_daemon != 'none') {

      if(empty($ntp_servers)) {
        fail("Can't configure ntp daemon without ntp servers")
      }

      case $ntp_daemon {

        'ntp': {
          validate_array($ntp_restrict)
          validate_array($ntp_servers)

          class { '::ntp':
            servers  => $ntp_servers,
            restrict => $ntp_restrict,
          }

          file { '/etc/sysconfig/ntpd':
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => 'OPTIONS="-u ntp:ntp"',
          }
        }

        'chrony': {
          validate_array($ntp_servers)

          class { 'chrony':
            servers      => $ntp_servers,
          }
        }

        default: {
          fail('This should never happen')
        }
      }
    }

  } else {

    echo { 'ntp-daemon':
      message  => $message,
      loglevel => $loglevel,
      withpath => false,
    }

    ::security_baseline::logging { 'ntp-test':
        rulenr    => 'ntp-test',
        rule      => 'ntp',
        desc      => 'Test',
        level     => $loglevel,
        msg       => $message,
        rulestate => 'not compliant',
      }
  }
}

# Report processor integration with Pagerduty
class pagerduty(
  $pagerduty_puppet_api        = 'SET ME',
  $pagerduty_puppet_reports    = '',
  $pagerduty_puppet_pluginsync = '',
) {

  package { 'redphone':
    ensure   => installed,
    provider => gem,
  }

  package { 'json':
    ensure   => installed,
    provider => gem,
  }

  file { '/etc/puppet/pagerduty.yaml':
    path    => '/etc/puppet/pagerduty.yaml',
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('pagerduty/pagerduty.yaml.erb'),
  }

  if $pagerduty_puppet_reports {
    ini_setting { 'pagerduty_puppet_reports':
      ensure  => present,
      path    => '/etc/puppet/puppet.conf',
      section => 'master',
      setting => 'reports',
      value   => $pagerduty_puppet_reports,
      notify  => Service['apache2'],
    }
  }

  if $pagerduty_puppet_pluginsync {
    ini_setting { 'pagerduty_puppet_pluginsync':
      ensure  => present,
      path    => '/etc/puppet/puppet.conf',
      section => 'main',
      setting => 'pluginsync',
      value   => $pagerduty_puppet_pluginsync,
      notify  => Service['apache2'],
    }
  }

}

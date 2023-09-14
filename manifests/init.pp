class syslog_ng {
  service { "rsyslog":
    ensure => false,
    enable => false,
  }
  -> systemd::unit_file { "rsyslog.service":
    enable => false,
    active => false,
    ensure => absent,
  }
  -> package { "rsyslog":
    ensure => purged,
  }
  -> class { "${module_name}::install": }
  -> class { "${module_name}::config": }
  -> class { "${module_name}::service": }
  -> class { "${module_name}::monitoring": }
}

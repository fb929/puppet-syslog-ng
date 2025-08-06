class syslog_ng (
  Optional[Hash] $conf_d = undef, # configuration conf.d files over hiera
){
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

  if $conf_d != undef {
    ensure_resources( 'syslog_ng::cfg', $conf_d )
  }
}

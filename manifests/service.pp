class syslog_ng::service {
  service { "syslog-ng":
    ensure => true,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}

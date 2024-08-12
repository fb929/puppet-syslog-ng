class syslog_ng::config (
  Integer $logrotate_count,
  String $logrotate_maxsize,
  String $conf_dir,
  Hash $cfg,
  Boolean $control_logrotate_dir,
  Boolean $send_remote,
  Boolean $dnf_log_config,
) {
  if $control_logrotate_dir {
    file {
      # logrotate {{
      "/etc/logrotate.d":
        ensure => directory,
        recurse => true,
        purge => true,
        force => true,
        source => "puppet:///modules/${module_name}/logrotate.d",
      ;
      "/etc/cron.hourly/logrotate":
        ensure => link,
        target => "../cron.daily/logrotate",
      ;
      # }}
    }
  }
  file {
    [
      "/etc/syslog-ng",
      "$conf_dir",
    ]:
      ensure => directory,
      recurse => true,
      purge => true,
      force => true,
      notify => Service["syslog-ng"],
    ;
    "/etc/syslog-ng/syslog-ng.conf":
      content => template("${module_name}/syslog-ng.conf.erb"),
      notify => Service["syslog-ng"],
    ;
  }
  systemd::unit_file { "syslog.service":
    target => "/etc/systemd/system/syslog-ng.service",
  }
  systemd::unit_file { "syslog-ng.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
  tools::file { "killDeleted.sh": source => "puppet:///modules/${module_name}/killDeleted.sh" }
  $cfg['destination']['remote'].each |$destination_name, $destination_settings| {
    file {
      [
        $destination_settings['disk_buffer']['dir'],
      ]:
        ensure => directory,
        mode => "0700",
        require => File["/var/log/syslog-ng"],
      ;
    }
  }
  file {
    [
      "/var/log/syslog-ng",
    ]:
      ensure => directory,
      mode => "0700",
    ;
  }
  -> syslog_ng::cfg {
    "destinations":
      order => 00,
      content => template("${module_name}/destinations.conf.erb"),
      logrotate => false,
    ;
    "systemd": send_remote => false;
    "sshd": send_remote => false;
  }
  if $dnf_log_config {
    syslog_ng::cfg { "dnf": send_remote => false; }
  }
}

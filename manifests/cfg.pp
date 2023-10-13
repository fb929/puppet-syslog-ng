define syslog_ng::cfg (
  Integer $order = 50, # default order for config file
  String $program = "^${name}\$", # default program regex
  Variant[String, Boolean] $to_program = false, # rewrite to program
  Optional[String] $content = undef, # custom template
  Boolean $logrotate = true, # enable\disable logrotate config
  Integer $logrotate_count = $::syslog_ng::config::logrotate_count, # default logrotate_count
  Optional[String] $logrotate_content = undef, # template for logrotate
  # options for default template {{
  String $logdir = "/var/log/$name",
  Boolean $send_remote = $::syslog_ng::config::send_remote, # send to remote syslog server
  Boolean $save_local_file = true, # save to local file
  Boolean $error_level = true, # writing a separate error level to a file and sending it to a remote server
  String $template = "t_long" # default template for log
  # }}
) {
  include ::syslog_ng

  $conf_dir = $::syslog_ng::config::conf_dir
  $_order = sprintf("%02d", $order)
  $syslog_conf = "$conf_dir/${_order}_$name.conf"

  if $content {
    $_content = $content
  } else {
    $_content = template("syslog_ng/cfg.conf.erb")
  }
  if $logrotate_content {
    $_logrotate_content = $logrotate_content
  } else {
    $_logrotate_content = template("syslog_ng/cfg.logrotate.erb")
  }

  file {
    $syslog_conf:
      content => $_content,
      require => File[$conf_dir],
      notify => Service["syslog-ng"],
    ;
  }
  if $logrotate {
    file {
      "/etc/logrotate.d/$name":
        content => $_logrotate_content,
      ;
    }
  }
}

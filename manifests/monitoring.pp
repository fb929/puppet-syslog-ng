class syslog_ng::monitoring (
  Boolean $collectd,
  ) {
  if $collectd {
    collectd::bin { "syslog_ng_stats.py": content => template("${module_name}/syslog_ng_stats.py") }
    -> collectd::cfg {
      "syslog_ng_stats": content => template("${module_name}/collectd.conf.erb");
      "syslog_ng_process": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    Process \"syslog-ng\"\n</Plugin>\n")
    }
  }
}

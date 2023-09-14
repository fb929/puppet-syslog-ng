# syslog-ng
## configuration
adding in hiera:
```
syslog_ng::config::cfg:
  destination:
    remote:
      # syslog host for collecting all logs
      syslog:
        host: <YOUR_SYSLOG_HOST>
        port: 514
        persist_name: syslog
        disk_buffer:
          enable: true
          dir: /var/log/syslog-ng/disk-buffer-syslog
```
## usage
```
syslog_ng::cfg { "program_name": }
syslog_ng::cfg { $module_name: }
```
other options see in manifests/cfg.pp

## [Reference](REFERENCE.md)

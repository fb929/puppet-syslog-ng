class syslog_ng::install (
  Hash $packages,
  Hash $githubartifact,
) {
  case $facts['os']['family'] {
    "RedHat": {
      ensure_resources("githubartifact::install", $githubartifact)
    }
    "Debian": {
      $distro_codename = $facts['os']['distro']['codename']
      apt::key { "2E6994033390DE82D8E6A2D16E187A4C6694369F":
        source => "https://ose-repo.syslog-ng.com/apt/syslog-ng-ose-pub.asc",
      }
      -> apt::source { "syslog-ng-ose":
        location => "https://ose-repo.syslog-ng.com/apt/",
        release => "stable",
        repos => "ubuntu-$distro_codename",
        before => Package[keys($packages)],
      }
      ensure_resources(
        package,
        $packages,
        {
          ensure => present,
          notify => Service["syslog-ng"],
        }
      )
    }
  }
}

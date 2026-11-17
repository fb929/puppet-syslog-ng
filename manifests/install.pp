class syslog_ng::install (
  Variant[Hash,Boolean] $packages = false,
  Variant[Hash,Boolean] $githubartifact = false,
) {
  case $facts['os']['family'] {
    "RedHat": {
      if $githubartifact {
        ensure_resources("githubartifact::install", $githubartifact)
      } elsif $packages {
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
    "Debian": {
      if $packages {
        $distro_id = downcase($facts['os']['distro']['id'])
        $distro_codename = $facts['os']['distro']['codename']
        apt::source { "syslog-ng-ose":
          location => "https://ose-repo.syslog-ng.com/apt/",
          release => "stable",
          repos => "${distro_id}-${distro_codename}",
          key => {
            "name"   => "syslog-ng-ose.asc",
            "source" => "https://ose-repo.syslog-ng.com/apt/syslog-ng-ose-pub.asc",
          },
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
}

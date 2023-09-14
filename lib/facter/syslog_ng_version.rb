Facter.add(:syslog_ng_version) do
  setcode do
    version = Facter::Util::Resolution.exec("syslog-ng --version 2>/dev/null | grep 'Config version' | awk '{print $NF}'")
    if version == ""
        version = Facter::Util::Resolution.exec("syslog-ng --version 2>/dev/null | head -1 | awk '{print $NF}'")
    end
    version
  end
end

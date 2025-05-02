Facter.add('logrotate_timer_available') do
  confine :kernel => 'Linux'
  setcode do
    File.exist?('/usr/lib/systemd/system/logrotate.timer') ||
    File.exist?('/etc/systemd/system/logrotate.timer')
  end
end

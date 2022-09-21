class profile::pe_backups (
  String               $cron_user      = 'root',
  Stdlib::Absolutepath $backup_dir     = '/var/puppetlabs/backups',
  Integer[1]           $days_to_keep   = 30,
  Integer[0, 23]       $backup_hour    = 21,
  Integer[0, 59]       $backup_minute  = 0,
  Integer[0, 23]       $cleanup_hour   = 23,
  Integer[0, 59]       $cleanup_minute = 0,
){

  $_a_string = sprintf('%02d', $backup_minute)
  echo { "${backup_minute} => ${_a_string}": }

  cron {
    default:
      ensure => present,
      user   => $cron_user,
      ;
    'Create Daily PE Backup':
      command => "/opt/puppetlabs/bin/puppet backup create --dir=${backup_dir} > /dev/null 2>&1",
      hour    => '21',
      minute  => '00',
      ;
    'Clean Old PE Backups':
      command => "/usr/bin/find ${backup_dir} -type f -mtime +${days_to_keep} -name *.tgz -delete",
      hour    => '23',
      minute  => '00',
      ;
  }

}

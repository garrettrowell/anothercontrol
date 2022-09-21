class profile::pe_backups (
  String[1]            $cron_user      = 'root',
  Stdlib::Absolutepath $backup_dir     = '/var/puppetlabs/backups',
  Integer[1]           $days_to_keep   = 30,
  Integer[0, 23]       $backup_hour    = 21,
  Integer[0, 59]       $backup_minute  = 0,
  Integer[0, 23]       $cleanup_hour   = 23,
  Integer[0, 59]       $cleanup_minute = 0,
){

  cron {
    default:
      ensure => present,
      user   => $cron_user,
      ;
    'Create Daily PE Backup':
      command => "/opt/puppetlabs/bin/puppet backup create --dir=${backup_dir} > /dev/null 2>&1",
      hour    => $backup_hour,
      minute  => $backup_minute,
      ;
    'Clean Old PE Backups':
      command => "/usr/bin/find ${backup_dir} -type f -mtime +${days_to_keep} -name *.tgz -delete",
      hour    => $cleanup_hour,
      minute  => $cleanup_minute,
      ;
  }

}

# @summary Create PE backups daily by default at 9PM and cleanup old backups at 11PM.
#   By default keep 30 days worth of backups.
#
# @see https://puppet.com/docs/pe/2021.6/backing_up_and_restoring_pe.html
#
# @see https://forge.puppet.com/modules/puppetlabs/cron_core/reference
#
# @param cron_user
#   The user who owns the cron jobs configured
# @param backup_dir
#   The directory where backups should be stored
# @param backup_scope
#   The scope passed to the backup create command
# @param days_to_keep
#   The number of days worth of backups to keep
# @param backup_hour
#   The hour when a backup will get created
# @param backup_minute
#   The minute when a backup will get created
# @param cleanup_hour
#   The hour when old backups will get cleaned
# @param cleanup_minute
#   The minute when old backups will get cleaned
#
# @example Create backups at 5:30PM, cleanup at 6:30PM and keep 7days of backups
#   ---
#   profile::pe_backups::backup_hour: 17
#   profile::pe_backups::backup_minute: 30
#   profile::pe_backups::cleanup_hour: 18
#   profile::pe_backups::cleanup_minute: 30
#   profile::pe_backups::days_to_keep: 7
#
class profile::pe_backups (
  String[1]            $cron_user      = 'root',
  Stdlib::Absolutepath $backup_dir     = '/var/puppetlabs/backups',
  Array[Enum[
      'certs',
      'code',
      'config',
      'puppetdb',
      'all',
  ], 1]                $backup_scope   = ['all'],
  Integer[1]           $days_to_keep   = 30,
  Integer[0, 23]       $backup_hour    = 21,
  Integer[0, 59]       $backup_minute  = 0,
  Integer[0, 23]       $cleanup_hour   = 23,
  Integer[0, 59]       $cleanup_minute = 0,
) {
  # Create comma separated string out of the array
  $_backup_scope = join($backup_scope, ',')

  cron {
    default:
      ensure => present,
      user   => $cron_user,
      ;
    'Create Daily PE Backup':
      command => "/opt/puppetlabs/bin/puppet backup create --dir=${backup_dir} --scope=${_backup_scope} > /dev/null 2>&1",
      hour    => $backup_hour,
      minute  => $backup_minute,
      ;
    'Clean Old PE Backups':
      command => "/usr/bin/find ${backup_dir} -type f -mtime +${days_to_keep} -name pe_backup*.tgz -delete",
      hour    => $cleanup_hour,
      minute  => $cleanup_minute,
      ;
  }
}

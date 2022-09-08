# This is a description for my plan
plan adhoc::myplan(
  # input parameters go here
  TargetSpec $targets,
) {

    $backup_result_or_error = run_task('exec', $target, 'command' => 'whoami', '_catch_errors' => true)
    $backup_result = case $backup_result_or_error {
      ResultSet: { $backup_result_or_error } # this is when successful
      Error['bolt/run-failure']: { $backup_result_or_error.details['result_set'] } # if an error extract its result set
      default: { fail_plan($backup_result_or_error) } # handle unexpected errors
    }
    run_task('exec', $backup_result.ok_set, 'command' => 'echo hello')

}

# This is a description for my plan
plan adhoc::myplan(
  # input parameters go here
  TargetSpec $targets,
) {

  #    $backup_result_or_error = run_task('exec', $targets, 'command' => 'whoami', '_catch_errors' => true)
  #    $backup_result = case $backup_result_or_error {
  #      ResultSet: { $backup_result_or_error } # this is when successful
  #      Error['bolt/run-failure']: { $backup_result_or_error.details['result_set'] } # if an error extract its result set
  #      default: { fail_plan($backup_result_or_error) } # handle unexpected errors
  #    }
  #    run_task('exec', get_targets($backup_result.ok_set), 'command' => 'echo hello')
  $result_or_error = run_task('exec', $targets, 'command' => 'whoami', '_catch_errors' => true)
  $result = case $result_or_error {
    # When the plan returned a ResultSet use it.
    ResultSet: { $result_or_error }
    # If the run_task failed extract the result set from the error.
    Error['bolt/run-failure'] : { $result_or_error.details['result_set'] }
    # The sub-plan failed for an unexpected reason.
    default : { fail_plan($result_or_error) } }
  # Run a task on the successful targets
  out::message("${result.targets}")
  run_task('exec', $result.targets, 'command' => 'echo hello')
}

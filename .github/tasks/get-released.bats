#!/usr/bin/env bats

setup() {
  SCRIPT="${BATS_TEST_DIRNAME}/get-released"
  PAYLOAD='{"releases_created":"true","apps/back-office--tag_name":"back-office-v1.0.0","apps/back-office--version":"1.0.0","paths_released":"[\"apps/back-office\"]"}'
}

@test "get-released (no subcommand) shows help" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"manifest"* ]]
  [[ "$output" == *"appnames"* ]]
}

@test "get-released help shows help" {
  run bash "$SCRIPT" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "get-released manifest outputs publish matrix entries" {
  run bash "$SCRIPT" manifest "$PAYLOAD" hotfix next
  [ "$status" -eq 0 ]

  run jq -e '. == [{"target":"back-office","tag":"next","mode":"hotfix","version":"1.0.0"}]' <<<"$output"
  [ "$status" -eq 0 ]
}

@test "get-released appnames outputs string[]" {
  run bash "$SCRIPT" appnames "$PAYLOAD"
  [ "$status" -eq 0 ]

  run jq -e '. == ["back-office"]' <<<"$output"
  [ "$status" -eq 0 ]
}

@test "manifest fails on missing payload" {
  run bash "$SCRIPT" manifest
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing JSON payload argument"* ]]
}

@test "appnames fails on invalid payload" {
  run bash "$SCRIPT" appnames '{not-json}'
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid JSON payload passed as argv[0]"* ]]
}

@test "manifest maps release-please paths to moon project ids" {
  payload='{"paths_released":["apps/api_service","pkgs/libs/hello"],"apps/api_service--version":"1.0.0","pkgs/libs/hello--version":"1.0.0"}'

  run bash "$SCRIPT" manifest "$payload" normal latest
  [ "$status" -eq 0 ]

  run jq -e '. == [{"target":"api-service","tag":"latest","mode":"normal","version":"1.0.0"},{"target":"hello-lib","tag":"latest","mode":"normal","version":"1.0.0"}]' <<<"$output"
  [ "$status" -eq 0 ]
}

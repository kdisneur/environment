#! /usr/bin/env bats

setup() {
  export PATH="${BATS_TEST_DIRNAME}/stubs:${BATS_TEST_DIRNAME}/../src:$PATH"
  export HOME="/my/home"

  unset NICE_VARIABLE_1;
  unset VARIABLE_ONLY_IN_DEV;
  unset VARIABLE_ONLY_IN_TEST;

  load ${BATS_TEST_DIRNAME}/../src/environment;
}

@test "_configPath: variable is overridable through environment variable" {
  [ ${_configPath} = "/my/home/.config/environment" ]

  export ENVIRONMENT_CONFIG_PATH="/another/place"
  load ${BATS_TEST_DIRNAME}/../src/environment;

  [ ${_configPath} = "/another/place" ]
}

@test "_currentEnvironmentName: variable is set through environment variable" {
  [ -z ${_currentEnvironmentName} ]

  export CURRENT_ENVIRONMENT_NAME="dummy"
  load ${BATS_TEST_DIRNAME}/../src/environment;

  [ ${_currentEnvironmentName} = "dummy" ]
}

@test "_ensureCurrentEnvironmentNameIsUndefined: when environment name is undefined" {
  run _ensureCurrentEnvironmentNameIsUndefined ""

  [ ${status} -eq 0 ]
}

@test "_ensureCurrentEnvironmentNameIsUndefined: when environment name is already defined" {
  run _ensureCurrentEnvironmentNameIsUndefined "dev"

  [ ${status} -eq 1 ]
  [ ${lines[0]} = "Already running in 'dev' environment." ]
}

@test "_error: when usage not set" {
  run _error "A nice message"

  [ ${status} -eq 1 ]
  [ ${output} = "A nice message" ]
}

@test "_error: when usage set to false" {
  run _error "false" "A nice message"

  [ ${status} -eq 1 ]
  [ ${output} = "A nice message" ]
}

@test "_error: when usage set to true" {
  run _error "true" "A nice message"

  [ ${status} -eq 1 ]
  [ ${lines[0]} = "A nice message" ]
  [[ ${lines[1]} =~ "Usage:" ]]
}

@test "_errorWithUsage: display the usage" {
  run _errorWithUsage "A nice message"

  [ ${status} -eq 1 ]
  [ ${lines[0]} = "A nice message" ]
  [[ ${lines[1]} =~ "Usage:" ]]
}

@test "_loadEnvironmentVariables: when file doesn't exist" {
  local file=${BATS_TEST_DIRNAME}/fixtures/nonexistingfile

  run _loadEnvironmentVariables "dev" ${file}

  [ ${status} -eq 1 ]
  [[ ${lines[0]} = "Environment file '${file}' doesn't exist." ]]
  [[ ${lines[1]} =~ "You can customize" ]]
  [[ ${lines[2]} =~ "Usage:" ]]
}

@test "_loadEnvironmentVariables: when file exist" {
  local file=${BATS_TEST_DIRNAME}/fixtures/dev

  _loadEnvironmentVariables "dev" ${file}

  [ "${MY_AWESOME_ENVIRONMENT_VARIABLE}" = "1337" ]
  [ "${ANOTHER_ONE}" = "Hello" ]
  [ "${CURRENT_ENVIRONMENT_NAME}" = "dev" ]
}

@test "_loadEnvironmentVariables: make sure CURRENT_ENVIRONMENT_NAME is set properly when file exist" {
  local file=${BATS_TEST_DIRNAME}/fixtures/dev

  _loadEnvironmentVariables "dev" ${file}
  [ "${CURRENT_ENVIRONMENT_NAME}" = "dev" ]

  _loadEnvironmentVariables "test" ${file}
  [ "${CURRENT_ENVIRONMENT_NAME}" = "test" ]
}

@test "_projectName: variable is overridable through environment variable" {
  [ ${_projectName} = "environment" ]

  export ENVIRONMENT_PROJECT_NAME="foo"
  load ${BATS_TEST_DIRNAME}/../src/environment;

  [ ${_projectName} = "foo" ]
}

@test "_spawnNewShell: should work" {
  run _spawnNewShell fakeShell

  [ ${output} = "fakeShell called with: -i" ]
}

@test "_validateScriptCanRun: when force is set to true" {
  run _validateScriptCanRun "true" "dev"

  [ ${status} -eq 0 ]
}

@test "_validateScriptCanRun: when force is set to false and current environment is not set" {
  run _validateScriptCanRun "false" ""

  [ ${status} -eq 0 ]
}

@test "_validateScriptCanRun: when force is set to false and current environment is set" {
  run _validateScriptCanRun "false" "dev"

  [ ${status} -eq 1 ]
  [ ${lines[0]} = "Already running in 'dev' environment." ]
}

@test "environment: -h display only usage message" {
  run environment -h

  [ ${status} -eq 0 ]
  [[ ${lines[0]} =~ "Usage:" ]]
}

@test "environment: when no environment is set" {
  ENVIRONMENT_CONFIG_PATH="${BATS_TEST_DIRNAME}/fixtures" \
  ENVIRONMENT_PROJECT_NAME="my_project" \
  SHELL=fakeShellPrintingEnvVars \
  run environment

  [ ${status} -eq 0 ]
  [[ "${output}" =~ CURRENT_ENVIRONMENT_NAME=dev \
    && "${output}" =~ NICE_VARIABLE_1=dev \
    && "${output}" =~ VARIABLE_ONLY_IN_DEV=yup \
    && ! "${output}" =~ VARIABLE_ONLY_IN_TEST=yup ]]
}

@test "environment: when environment is set to test" {
  ENVIRONMENT_CONFIG_PATH="${BATS_TEST_DIRNAME}/fixtures" \
  ENVIRONMENT_PROJECT_NAME="my_project" \
  SHELL=fakeShellPrintingEnvVars \
  run environment "test"

  [ ${status} -eq 0 ]
  [[ "${output}" =~ CURRENT_ENVIRONMENT_NAME=test \
    && "${output}" =~ NICE_VARIABLE_1=test \
    && "${output}" =~ VARIABLE_ONLY_IN_TEST=yup \
    && ! "${output}" =~ VARIABLE_ONLY_IN_DEV=yup ]]
}

@test "environment: when an environment is already loaded" {
  CURRENT_ENVIRONMENT_NAME=dev \
  ENVIRONMENT_CONFIG_PATH="${BATS_TEST_DIRNAME}/fixtures" \
  ENVIRONMENT_PROJECT_NAME="my_project" \
  SHELL=fakeShellPrintingEnvVars \
  run environment "test"

  [ ${status} -eq 1 ]
  [ ${lines[0]} = "Already running in 'dev' environment." ]
}

@test "environment: -f when an environment is already loaded" {
  CURRENT_ENVIRONMENT_NAME=dev \
  ENVIRONMENT_CONFIG_PATH="${BATS_TEST_DIRNAME}/fixtures" \
  ENVIRONMENT_PROJECT_NAME="my_project" \
  SHELL=fakeShellPrintingEnvVars \
  run environment -f "test"

  [ ${status} -eq 0 ]
  [[ "${output}" =~ CURRENT_ENVIRONMENT_NAME=test \
    && "${output}" =~ NICE_VARIABLE_1=test \
    && "${output}" =~ VARIABLE_ONLY_IN_TEST=yup ]]
}

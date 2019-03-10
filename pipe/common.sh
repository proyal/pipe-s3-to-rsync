#!/bin/bash

# This script is based on Atlassian's pipe example.
#
# Common script helper code for writing bash based pipes
# This file needs to be 'source'd from your bash script, i.e. `source common.sh`
# This supplies the `info()`, `error()`, `debug()`, `success()` and `fail()` command that will
# color the output consistently with other Pipes.
#
# We also recommend that your Pipe contain a `DEBUG` variable, which when set to `true`
# enables extra debug output - this can be achieved simply by calling the `enable_debug()`
# function from within your Pipe script and using the `debug()` function which will conditionally emit
# debugging information.

set -o pipefail

gray="\\033[37m"
blue="\\033[36m"
red="\\033[31m"
green="\\033[32m"
reset="\\033[0m"

# Output information to the Pipelines log for the user
info() { echo -e "${blue}INFO: $*${reset}"; }
# Output high-visibility error information
error() { echo -e "${red}ERROR: $*${reset}"; }
# Conditionally output debug information (if DEBUG==true)
debug() {
    if [[ "${DEBUG}" == "true" ]]; then
        echo -e "${gray}DEBUG: $*${reset}";
    fi
}

# Output log information indicating success
success() { echo -e "${green}✔ $*${reset}"; }
# Output log information indicating failure and exit the Pipe script
fail() { echo -e "${red}✖ $*${reset}"; exit 1; }

# Enable debug mode.
enable_debug() {
  if [[ "${DEBUG}" == "true" ]]; then
    info "Enabling debug mode."
    set -x
  fi
}

check_status() {
  if [[ "${status}" == "0" ]]; then
    success "Success!"
  else
    fail "Error!"
  fi
}

echo_var() {
  echo $1=\'${!1}\'
}

# Execute a command, saving its output and exit status code, and echoing its output upon completion.
# Globals set:
#   status: Exit status of the command that was executed.
#   output: Output generated from the command.
#
run() {
  echo + "$@"
  set +e
  eval $@
  status=$?
  set -e
  check_status
}

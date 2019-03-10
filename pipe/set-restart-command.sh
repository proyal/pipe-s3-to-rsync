#!/bin/bash
#
# This pipe executes a command to build a node project, zips it up, and uploads it to s3.
#
set_restart_command() {
  if [[ -z $RESTART_COMMAND ]]; then
    case $RESTART_COMMAND_TYPE in
      staging)
        RESTART_COMMAND="pm2 restart ${DEPLOY_PATH}/ecosystem.config.js --update-env";;
      production)
        RESTART_COMMAND="/usr/local/bin/restart-nodejs";;
     esac
  fi
}

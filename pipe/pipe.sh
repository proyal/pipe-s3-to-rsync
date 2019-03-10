#!/bin/bash
#
# This pipe executes a command to build a node project, zips it up, and uploads it to s3.
#

source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/set-restart-command.sh"

#
# Required parameters
#
AWS_REGION=${AWS_REGION:?'AWS_REGION variable missing.'}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?'AWS_ACCESS_KEY_ID variable missing.'}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?'AWS_SECRET_ACCESS_KEY variable missing.'}
S3_BUCKET=${S3_BUCKET:?'S3_BUCKET variable missing.'}
S3_FILENAME=${S3_FILENAME:?'S3_FILENAME variable missing.'}
DEPLOY_USERNAME=${DEPLOY_USERNAME:?'DEPLOY_USERNAME variable missing.'}
DEPLOY_ADDRESS=${DEPLOY_ADDRESS:?'DEPLOY_ADDRESS variable missing.'}
DEPLOY_PATH=${DEPLOY_PATH:?'DEPLOY_PATH variable missing.'}

#
# Default parameters
#
S3_FILENAME_REGEX=${S3_FILENAME_REGEX:='^[a-zA-Z0-9_/-]+\.zip$'}
UNZIP_PATH=${UNZIP_PATH:='.dist'}
SSH_TO=$DEPLOY_USERNAME@$DEPLOY_ADDRESS
RSYNC_TARGET=$SSH_TO:$DEPLOY_PATH
RUN_DEPENDENCIES_COMMAND=${RUN_DEPENDENCIES_COMMAND:=true}
DEPENDENCIES_COMMAND=${DEPENDENCIES_COMMAND:='npm ci --production'}
RESTART_COMMAND_TYPE=${RESTART_COMMAND_TYPE:=none}
RESTART_COMMAND=${RESTART_COMMAND:=''}

set_restart_command

#
# Echo non-sensitive variables that are about to be used.
#
echo_var AWS_REGION
echo_var S3_BUCKET
echo_var S3_FILENAME
echo_var DEPLOY_USERNAME
echo_var DEPLOY_ADDRESS
echo_var DEPLOY_PATH
echo
echo_var S3_FILENAME_REGEX
echo_var UNZIP_PATH
echo_var SSH_TO
echo_var RSYNC_TARGET
echo_var RUN_DEPENDENCIES_COMMAND
echo_var DEPENDENCIES_COMMAND
echo_var RESTART_COMMAND_TYPE
echo_var RESTART_COMMAND

#
# Begin the work.
#
run rm -rf $UNZIP_PATH
run aws s3 cp --region $AWS_REGION s3://$S3_BUCKET/$S3_FILENAME dist.zip
run unzip dist.zip -d $UNZIP_PATH
run rsync -avczhi --stats --delete --partial --exclude-from=rsync-exclude-from $UNZIP_PATH/ $SSH_TO:$DEPLOY_PATH
if [[ $RUN_DEPENDENCIES_COMMAND == true ]]; then
    run "ssh $SSH_TO \"cd $DEPLOY_PATH && $DEPENDENCIES_COMMAND\""
fi
if [[ $RESTART_COMMAND ]]; then
    run "ssh $SSH_TO \"cd $DEPLOY_PATH && $RESTART_COMMAND\""
fi

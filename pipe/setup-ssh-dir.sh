#!/bin/bash
#
# From Atlassian example pipe.
#
# Copy injected SSH config to container.
#
setup_ssh_dir() {
  INJECTED_SSH_CONFIG_DIR="/opt/atlassian/pipelines/agent/ssh"
  # The default ssh key with open perms readable by alt uids
  IDENTITY_FILE="${INJECTED_SSH_CONFIG_DIR}/id_rsa_tmp"
  # The default known_hosts file
  KNOWN_HOSTS_FILE="${INJECTED_SSH_CONFIG_DIR}/known_hosts"

  mkdir -p ~/.ssh || debug "adding ssh keys to existing ~/.ssh"
  touch ~/.ssh/authorized_keys

  # If given, use SSH_KEY, otherwise check if the default is configured and use it
  if [ "${SSH_KEY}" != "" ]; then
     debug "Using passed SSH_KEY"
     (umask  077 ; echo ${SSH_KEY} | base64 -d > ~/.ssh/pipelines_id)
  elif [ ! -f ${IDENTITY_FILE} ]; then
     error "No default SSH key configured in Pipelines."
     exit 1
  else
     debug "Using default ssh key"
     cp ${IDENTITY_FILE} ~/.ssh/pipelines_id
  fi

  if [ ! -f ${KNOWN_HOSTS_FILE} ]; then
      error "No SSH known_hosts configured in Pipelines."
      exit 2
  fi

  cat ${KNOWN_HOSTS_FILE} >> ~/.ssh/known_hosts
  if [ -f ~/.ssh/config ]; then
      debug "Appending to existing ~/.ssh/config file"
  fi
  echo "IdentityFile ~/.ssh/pipelines_id" >> ~/.ssh/config
  chmod -R go-rwx ~/.ssh/
}

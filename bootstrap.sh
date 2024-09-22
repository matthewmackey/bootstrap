#!/bin/bash

set -e
set -o pipefail

if [ "$BOOTSTRAP_DEBUG" = "y" ]; then
  set -x
fi


#------------------------------------------------------------------------------
# DEPENDENCIES
#------------------------------------------------------------------------------
ENV_COMMON_URL="https://raw.githubusercontent.com/matthewmackey/dotfiles/refs/heads/main/.config/sh/env"
LIB_COMMON_URL="https://raw.githubusercontent.com/matthewmackey/dotfiles/refs/heads/main/lib/common.sh"

# See: https://stackoverflow.com/questions/5735666/execute-bash-script-from-url
source <(curl -s $ENV_COMMON_URL)
source <(curl -s $LIB_COMMON_URL)


#------------------------------------------------------------------------------
# MAIN()
#------------------------------------------------------------------------------
USERNAME=mmackey
TMP_BOOTSTRAP_DIR=/tmp/bootstrap

export PERSONAL_DIR=$PERSONAL
ANSIBLE_ROOT=$PERSONAL_DIR/config-mgmt

#--------------------------------------------------------------------------------------"
#
#--------------------------------------------------------------------------------------"
section "Install 'git' and clone 'bootstrap' repo"
print_step "Ensuring git is installed"
sudo apt install -y git

# Clone bootstrap repository
print_step "Cloning bootstrap repo"
git clone https://github.com/matthewmackey/bootstrap.git $TMP_BOOTSTRAP_DIR
cd $TMP_BOOTSTRAP_DIR

#--------------------------------------------------------------------------------------"
#
#--------------------------------------------------------------------------------------"
section "Running: [bootstrap-pass-ssh-repos.sh]"
# Run script to clone and setup pass, SSH key and other repos needed for bootstrapping
./bootstrap-pass-ssh-repos.sh

#--------------------------------------------------------------------------------------"
#
#--------------------------------------------------------------------------------------"
section "Running: [bootstrap-asdf.sh]"
# Setup ASDF so we can install Python and pip to install Ansible
./bootstrap-asdf.sh

#--------------------------------------------------------------------------------------"
#
#--------------------------------------------------------------------------------------"
section "Running: [bootstrap-ansible.sh]"
# Install Ansible via pipx
./bootstrap-ansible.sh


## Run a bootstrap playbook using the tmp Ansible installation
##
## FYI, the `local` inventory file (possible corresponding `host_vars`) is something that is
## not checked into VCS in the `config- mgmt` repository b/c it can vary by machine.
#/tmp/ansible_tmp_python/ansible.sh \
#  -v \
#  -i $ANSIBLE_ROOT/local \
#  -e username=$USERNAME \
#  $ANSIBLE_ROOT/play-bootstrap.yml


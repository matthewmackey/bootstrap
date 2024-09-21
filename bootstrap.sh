#!/bin/bash

set -e

# TODO: how to figure out dependency on the PERSONAL_DIR variable with the other
# dotfile-related repos
export PERSONAL_DIR=~/.personal

ANSIBLE_ROOT=$PERSONAL_DIR/config-mgmt
USERNAME=mmackey
TMP_BOOTSTRAP_DIR=/tmp/bootstrap

# Clone bootstrap repository
git clone https://github.com/matthewmackey/bootstrap.git $TMP_BOOTSTRAP_DIR
cd $TMP_BOOTSTRAP_DIR

# Run script to clone and setup pass, SSH key and other repos needed for bootstrapping
./bootstrap-pass-ssh-repos.sh

# Setup ASDF so we can install Python and pip to create an Ansible virtualenv
./bootstrap-asdf.sh

# Run script to setup a tmp Ansible installation we can use to bootstrap a real Ansible installation


# Run a bootstrap playbook using the tmp Ansible installation
#
# FYI, the `local` inventory file (possible corresponding `host_vars`) is something that is
# not checked into VCS in the `config- mgmt` repository b/c it can vary by machine.
/tmp/ansible_tmp_python/ansible.sh \
  -v \
  -i $ANSIBLE_ROOT/local \
  -e username=$USERNAME \
  $ANSIBLE_ROOT/play-bootstrap.yml

# Use the new Python installed by the bootstrap playbook to create a permanent Ansible installation
mkvirtualenv ansible
pip install ansible

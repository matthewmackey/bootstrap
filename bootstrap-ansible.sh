#!/bin/bash

set -e
set -o pipefail


#------------------------------------------------------------------------------
# DEPENDENCIES
#------------------------------------------------------------------------------
ENV_COMMON_URL="https://raw.githubusercontent.com/matthewmackey/dotfiles/refs/heads/main/.config/sh/env"
LIB_COMMON_URL="https://raw.githubusercontent.com/matthewmackey/dotfiles/refs/heads/main/lib/common.sh"

# See: https://stackoverflow.com/questions/5735666/execute-bash-script-from-url
source <(curl -s $ENV_COMMON_URL)
source <(curl -s $LIB_COMMON_URL)


#------------------------------------------------------------------------------
# CONSTANTS
#------------------------------------------------------------------------------
DEFAULT_PYTHON_VERSION=3.8.9
DEFAULT_PIP_BIN=$ASDF_HOME/installs/python/$DEFAULT_PYTHON_VERSION/bin/pip
DEFAULT_PIPX_BIN=$ASDF_HOME/installs/python/$DEFAULT_PYTHON_VERSION/bin/pipx


#------------------------------------------------------------------------------
# STEPS
#------------------------------------------------------------------------------
install_default_python_with_asdf() {
  print_step "Installing Default Python version with asdf"
  asdf install python $DEFAULT_PYTHON_VERSION
}


install_pipx_into_default_python() {
  print_step "Installing 'pipx' into Default Python"
  $DEFAULT_PIP_BIN install pipx
  $DEFAULT_PIPX_BIN ensurepath
}

install_ansible_with_pipx() {
  print_step "Installing Ansible with pipx"
  $DEFAULT_PIPX_BIN install --include-deps ansible
}


#------------------------------------------------------------------------------
# MAIN()
#------------------------------------------------------------------------------
# Enable `asdf` to get access to `asdf plugin` commands
source_file_if_exists_or_fail $ASDF_HOME/asdf.sh

main() {
  install_default_python_with_asdf
  install_pipx_into_default_python
  install_ansible_with_pipx
}

main

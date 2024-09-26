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
# CONSTANTS
#------------------------------------------------------------------------------
# All vars below from: .config/sh/env


#------------------------------------------------------------------------------
# STEPS
#------------------------------------------------------------------------------
install_ansible_with_pipx() {
  print_step "Installing Ansible with pipx"
  $DEFAULT_ASDF_PIPX install --include-deps ansible
}


#------------------------------------------------------------------------------
# MAIN()
#------------------------------------------------------------------------------
main() {
  install_ansible_with_pipx
}

main

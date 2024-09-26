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
#
# The following method ensures that we are using an ASDF-installed python version
# versus the OS system Python for all Python work.  This keeps our system
# Python clean.
#
# The only packages that ever get installed into this ASDF-installed Python
# however are 'virtualenvwrapper' and 'pipx'.
#
# If we need to install any other Python packages, then we either:
#
#   - use 'pipx' to install the package globally, or
#   - create a virtualenv with 'virtualenvwrapper' and install the package(s) there
#
#------------------------------------------------------------------------------
install_default_python_with_asdf() {
  print_step "Installing Default Python version with asdf"
  asdf install python $DEFAULT_ASDF_PYTHON_VERSION
}

install_virtualenvwrapper_into_asdf_default_python() {
  print_step "Installing 'virtualenvwrapper' into ASDF_DEFAULT_PYTHON"
  $DEFAULT_ASDF_PYTHON_PIP install virtualenvwrapper
}

install_pipx_into_asdf_default_python() {
  print_step "Installing 'pipx' into ASDF_DEFAULT_PYTHON"
  $DEFAULT_ASDF_PYTHON_PIP install pipx
}

# REFERENCE of older "DEFAULT_PYTHON" method:
#
# create_virtualenv_default_python_from_asdf_default_python() {
#   print_step "Create the DEFAULT_PYTHON virtualenv based off of the asdf default Python"
#   $DEFAULT_ASDF_PYTHON_BIN -m venv --copies $DEFAULT_PYTHON
# }

# install_virtualenvwrapper_into_default_python() {
#   print_step "Installing 'virtualenvwrapper' into DEFAULT_PYTHON"
#   $DEFAULT_PYTHON_PIP_BIN install virtualenvwrapper
# }

# install_pipx_into_default_python() {
#   print_step "Installing 'pipx' into DEFAULT_PYTHON"
#   $DEFAULT_PYTHON_PIP_BIN install pipx
# }


#------------------------------------------------------------------------------
# MAIN()
#------------------------------------------------------------------------------
# Enable `asdf` to get access to `asdf plugin` commands
source_file_if_exists_or_fail $ASDF_HOME/asdf.sh

main() {
  install_default_python_with_asdf
  install_virtualenvwrapper_into_asdf_default_python
  install_pipx_into_asdf_default_python
}

main

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
# gpg
GPG_KEY_TYPE=RSA
GPG_KEY_LENGTH=4096
GPG_NAME="Matthew Mackey"
GPG_EMAIL="matthew.mackey.dev@gmail.com"

# pass
PASS_DIR=~/.password-store
PASS_DEFAULT_SSH_PASSPHRASE_PATH="ssh/default"

# ssh
SSH_KEY_TYPE=rsa
SSH_KEY_LENGTH=4096
SSH_PASSPHRASE_LENGTH=20
DEFAULT_SSH_KEY_FILE=~/.ssh/id_rsa

# github
GITHUB_USER=matthewmackey
GITHUB_NAME="Matthew Mackey"
GITHUB_EMAIL="21043873+matthewmackey@users.noreply.github.com"
GITHUB_BASE_REPO=https://github.com/$GITHUB_USER

# 'personal' bootstrap system
# Note: cloning 'bootstrap' here b/c it was just cloned to a temp dir during bootstrap process
PERSONAL_BOOTSTRAP_DIR=$PERSONAL_DIR/bootstrap
PERSONAL_BIN_DIR=$PERSONAL_DIR/bin
PERSONAL_CONFIG_MGMT_DIR=$PERSONAL_DIR/config-mgmt
PERSONAL_DOTFILES_DIR=$PERSONAL_DIR/dotfiles

PERSONAL_BOOTSTRAP_REPO=$GITHUB_BASE_REPO/bootstrap.git
PERSONAL_BIN_REPO=$GITHUB_BASE_REPO/bin.git
PERSONAL_DOTFILES_REPO=$GITHUB_BASE_REPO/dotfiles.git
PERSONAL_CONFIG_MGMT_REPO=$GITHUB_BASE_REPO/config-mgmt.git

#-------------------------------------------------------------------------------
# Helper methods
#-------------------------------------------------------------------------------
skip_if_exists() {
  local _file_to_test_if_exists=$1
  local _skip_msg=$2

  if [ -e $_file_to_test_if_exists ]; then
    printf "$_skip_msg\n"
    printf "[$_file_to_test_if_exists] already exists...skipping step\n"
    return 1
  else
    return 0
  fi
}

set_local_git_config() {
  local _name="$1"
  local _email="$2"

  msg "Setting local git config user.name: [$_name]"
  git config --local user.name "$_name"

  msg "Setting local git config user.email: [$_email]"
  git config --local user.email "$_email"
}


#-------------------------------------------------------------------------------
# Steps:
#-------------------------------------------------------------------------------
gather_computer_id_for_ssh_key_comment() {
  print_step "Gather Computer ID"

  if [ -z "$COMPUTER_ID" ]; then
    _prompt="What do you want to use as the ID for this computer (ie - $COMPUTER_ID)? "
    read -p "$_prompt" COMPUTER_ID
  else
    skipping "COMPUTER_ID already exists in the environment so using that value: [$COMPUTER_ID]"
  fi
}

gather_computer_name_for_gpg_key_info() {
  print_step "Gather Computer Name"

  if [ -z "$COMPUTER_NAME" ]; then
    _prompt="What do you want to use as the name for this computer (ie - '$COMPUTER_NAME')? "
    read -p "$_prompt" COMPUTER_NAME
  else
    skipping "COMPUTER_NAME already exists in the environment so using that value: [$COMPUTER_NAME]"
  fi
}

install_packages() {
  print_step "Install required packages"

  if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -60)" ]; then
    sudo apt-get update
  else
    skipping "APT cache was updated within last 60 minutes"
  fi

  print_step "Installing gpg | git | pass"
  sudo apt-get install -y gpg git pass
}

generate_gpg_key() {
  print_step "Generate GPG key for [$GPG_EMAIL]"

  if gpg --list-keys $GPG_EMAIL >& /dev/null; then
    printf "GPG key already exists for [$GPG_EMAIL]...skipping step\n"
    return 0
  fi

  cat <<EOF | gpg --gen-key --batch
Key-Type: $GPG_KEY_TYPE
Key-Length: $GPG_KEY_LENGTH
Subkey-Type: $GPG_KEY_TYPE
Subkey-Length: $GPG_KEY_LENGTH
Name-Real: $GPG_NAME
Name-Email: $GPG_EMAIL
Name-Comment: $GPG_COMMENT
Expire-Date: 0
%commit
EOF
}

# We need to set this globally before running `pass git init` b/c the .git
# folder inside of the PASS_DIR will not exist until after `pass git init`
# is run so we couldn't set them using the `git config --local` option
set_global_gitconfig_user_name_and_email() {
  print_step "Configure global git config w/ 'user.name' and 'user.email'"

  msg "Setting global git config user.name: [$GITHUB_NAME]"
  git config --global user.name "$GITHUB_NAME"

  msg "Setting global git config user.email: [$GITHUB_EMAIL]"
  git config --global user.email "$GITHUB_EMAIL"
}

initialize_pass_repo() {
  print_step "Initialize 'pass' repository"

  _skip_msg="'pass' repository has already been initialized"
  skip_if_exists $PASS_DIR "$_skip_msg" || return 0

  pass init "$GPG_EMAIL"

  msg "Initializing 'pass' git repository\n"
  pass git init

  cd $PASS_DIR
  set_local_git_config "$GITHUB_NAME" "$GITHUB_EMAIL"
}

gather_and_store_ssh_key_passphrase() {
  print_step "Gather passphrase for default SSH key & insert into 'pass' repo"

  printf "The following passphrase prompt will be for the your default SSH key ($DEFAULT_SSH_KEY_FILE).\n"
  printf "The passphrase will be stored in your 'pass' repo at the key '$PASS_DEFAULT_SSH_PASSPHRASE_PATH'.\n\n"
  read -p "Hit ENTER to continue "
  printf "\n"
  pass insert "$PASS_DEFAULT_SSH_PASSPHRASE_PATH"
}

generate_and_store_ssh_key_passphrase() {
  print_step "Generate random passphrase for default SSH key & insert into 'pass' repo"

  pass generate --no-symbols "$PASS_DEFAULT_SSH_PASSPHRASE_PATH" $SSH_PASSPHRASE_LENGTH > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    msg "A random passphrase was stored in your 'pass' repo at the key: [$PASS_DEFAULT_SSH_PASSPHRASE_PATH]"
  else
    fail "Error generating random passphrase for SSH key with 'pass'"
    exit 1
  fi
}

generate_ssh_key() {
  print_step "Generate default SSH key"

  _skip_msg="Default SSH key already exists"
  skip_if_exists $DEFAULT_SSH_KEY_FILE "$_skip_msg" || return 0

  printf "You will now be prompted for your GPG passphrase to retrieve the SSH passphrase that was just added to your 'pass' repo.\n"
  printf "The passphrase will then be used with'ssh-keygen' to create your default SSH key.\n\n"
  read -p "Hit ENTER to continue "
  printf "\n"
  ssh-keygen -t $SSH_KEY_TYPE -b $SSH_KEY_LENGTH -f $DEFAULT_SSH_KEY_FILE \
    -C "$SSH_COMMENT" \
    -N "$(pass show "$PASS_DEFAULT_SSH_PASSPHRASE_PATH")"
}

ensure_personal_dir_exists() {
  print_step "Ensuring PERSONAL_DIR exists"

  if [ ! -d "$PERSONAL_DIR" ]; then
    mkdir "$PERSONAL_DIR"
    msg "PERSONAL_DIR created"
  else
    msg "PERSONAL_DIR already existed"
  fi
}

clone_dot_personal_repos() {
  clone_if_not_exist $PERSONAL_BOOTSTRAP_DIR $PERSONAL_BOOTSTRAP_REPO
  clone_if_not_exist $PERSONAL_BIN_DIR $PERSONAL_BIN_REPO
  clone_if_not_exist $PERSONAL_DOTFILES_DIR $PERSONAL_DOTFILES_REPO
  clone_if_not_exist $PERSONAL_CONFIG_MGMT_DIR $PERSONAL_CONFIG_MGMT_REPO
}

clone_if_not_exist() {
  local _clone_dir=$1
  local _clone_url=$2

  print_step "Cloning [$_clone_url]"

  _skip_msg=".personal git repo [$_clone_url] already cloned"
  skip_if_exists $_clone_dir || return 0

  git clone $_clone_url $_clone_dir
  (
    cd $_clone_dir
    set_local_git_config "$GITHUB_NAME" "$GITHUB_EMAIL"
  )
}


#-------------------------------------------------------------------------------
# main()
#-------------------------------------------------------------------------------
install_packages

gather_computer_id_for_ssh_key_comment
gather_computer_name_for_gpg_key_info

GPG_COMMENT="$COMPUTER_NAME"
generate_gpg_key

set_global_gitconfig_user_name_and_email
initialize_pass_repo

SSH_COMMENT="$USER-$COMPUTER_ID"
# gather_and_store_ssh_key_passphrase
generate_and_store_ssh_key_passphrase
generate_ssh_key

ensure_personal_dir_exists
clone_dot_personal_repos

#!/bin/bash

GPG_KEY_TYPE=RSA
GPG_KEY_LENGTH=4096

GPG_NAME="Matthew Machaj"
GPG_EMAIL="matthew.mackey.dev@gmail.com"
GPG_COMMENT="<COMPUTER_NAME>"

SSH_KEY_TYPE=rsa
SSH_KEY_LENGTH=4096
DEFAULT_SSH_KEY_FILE=~/.ssh/id_rsa2

PASS_DEFAULT_SSH_PASSPHRASE_PATH="ssh/default"


print_step() {
  printf "\n"
  printf "#-------------------------------------------------------------------------------\n"
  printf "# $1\n"
  printf "#-------------------------------------------------------------------------------\n"
}


install_packages() {
  sudo apt-get update
  sudo apt-get install -y git pass
}

generate_gpg_key() {
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

gather_computer_id() {
  print_step "Gather Computer ID"

  _prompt="What do you want to use as the ID for this computer (ie - $COMPUTER_ID)? "
  read -p "$_prompt" COMPUTER_ID
}

gather_computer_name() {
  print_step "Gather Computer Name"

  _prompt="What do you want to use as the name for this computer (ie - '$COMPUTER_NAME')? "
  read -p "$_prompt" COMPUTER_NAME
}


initialize_pass_repo() {
  print_step "Initialize 'pass' repository"
  pass init "$GPG_EMAIL"
  pass git init
}

gather_ssh_key_passphrase() {
  print_step "Gather passphrase for default SSH key & insert into 'pass' repo"

  printf "The following passphrase prompt will be for the your default SSH key ($DEFAULT_SSH_KEY_FILE).\n"
  printf "The passphrase will be stored in your 'pass' repo at the key '$PASS_DEFAULT_SSH_PASSPHRASE_PATH'.\n\n"
  read -p "Hit ENTER to continue "
  printf "\n"
  pass insert "$PASS_DEFAULT_SSH_PASSPHRASE_PATH"
}

generate_ssh_key() {
  print_step "Generate default SSH key"

  printf "You will now be prompted for your GPG passphrase to retrieve the SSH passphrase that was just added to your 'pass' repo.\n"
  printf "The passphrase will then be used with'ssh-keygen' to create your default SSH key.\n\n"
  read -p "Hit ENTER to continue "
  printf "\n"
  ssh-keygen -t $SSH_KEY_TYPE -b $SSH_KEY_LENGTH -f $DEFAULT_SSH_KEY_FILE \
    -C "$SSH_COMMENT" \
    -N "$(pass show "$PASS_DEFAULT_SSH_PASSPHRASE_PATH")"
}


main() {

  COMPUTER_NAME="Lenovo laptop"
  gather_computer_name

  # install_packages
  # generate_gpg_key
}

COMPUTER_NAME="Lenovo laptop"
gather_computer_name

COMPUTER_ID="mmlenovo"
gather_computer_id

initialize_pass_repo
gather_ssh_key_passphrase

SSH_COMMENT="$USER-$COMPUTER_ID"
generate_ssh_key

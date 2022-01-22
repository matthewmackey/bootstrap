#!/bin/bash

GPG_KEY_TYPE=RSA
GPG_KEY_LENGTH=4096

GPG_NAME="Matthew Machaj"
GPG_EMAIL="matthew.mackey.dev@gmail.com"
GPG_COMMENT="<COMPUTER_NAME>"


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

generate_ssh_key() {
:
}

gather_computer_id() {
  _prompt="What do you want to use as the ID for this computer (ie - $COMPUTER_ID)? "
  read -p "$_prompt" COMPUTER_ID
}

gather_computer_name() {
  _prompt="What do you want to use as the name for this computer (ie - '$COMPUTER_NAME')? "
  read -p "$_prompt" COMPUTER_NAME
}

COMPUTER_ID="mmlenovo"
gather_computer_id
echo $COMPUTER_ID

COMPUTER_NAME="Lenovo laptop"
gather_computer_name
echo $COMPUTER_NAME

# install_packages
# generate_gpg_key
# generate_ssh_key

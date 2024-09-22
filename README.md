Bootstrap Instructions
======================

TLDR;
-----

Run the following commands to bootstrap a new system:

```sh
curl -o bootstrap.sh https://raw.githubusercontent.com/matthewmackey/bootstrap/main/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh && rm ./bootstrap.sh
 ```


Optional Environment Variables
------------------------------

The following environment variables can be set to affect how bootstrap will run:

```sh
#
# OPTIONAL: BOOTSTRAP_DEBUG
#
# Runs Bash scripts with `set -x`
# Does nothing if not set to `y`
export BOOTSTRAP_DEBUG=y

#
# OPTIONAL: COMPUTER_ID
#
# Sets computer ID which is used in the generated SSH key's comment
# If not, provided you will be prompted for this.
export COMPUTER_ID=my-computer-id

#
# OPTIONAL: COMPUTER_NAME
#
# Sets computer name which is used as the generated GPG key's comment
# If not, provided you will be prompted for this.
export COMPUTER_NAME="My computer name"
```

The following environment variables are relevant when running bootstrap over an
SSH session:

```sh
#
# OPTIONAL: UNSAFE_PRINT
#
# If running bootstrap over interactive SSH, then you should set this to `y` to be able to
# see script pretty-printed progress comments.
#
# If not explicitly set to `y`, then pretty printing is turned off over interactive SSH.
export UNSAFE_PRINT=y

#
# OPTIONAL: GPG_TTY
#
# Run the following command on the remote host 1st if you are running bootstrap remotely over SSH:
export GPG_TTY=$(tty)
```

### Note on GPG_TTY

If running this remotely, then we need to set the GPG_TTY variable or else the `gpg` utility
can't prompt us for our GPG passphrase.

You can see here for more info:

- https://stackoverflow.com/questions/51504367/gpg-agent-forwarding-inappropriate-ioctl-for-device

I don't want to use the `ssh -X` method also mentioned on this page because of comments in
the SSH man page regarding X11 Forwarding security risks (which `-X` is for).

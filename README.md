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

Security Issues
---------------

Because there is no way to read a passphrase from STDIN when using `ssh-keygen`
when creating a new SSH keypair, the `ssh-keygen` command in the `bootstrap-pass-ssh-repos.sh`
script is unsafe because the SSH passphrase will show:

- in the `ps` output while the script is running
- or, if the Bash script is run with `set -x` like when setting `BOOTSTRAP_DEBUG=y`

In order to automate things, this trade-off has been made because we can run in
non-`BOOTSTRAP_DEBUG` mode and someone would have to be on the system at the same time
we are running the script to view `ps` output (or they would have already compromised
the machine to spy on `ps` persistently, in which case we already have a big
problem).

Saving the passphrase to a file doesn't help because the `-N` option of
`ssh-keygen` doesn't allow us to specify a filename.  And even if it would allow
it, then we would have to deal with the security implications of storing the
passphrase in a file.

### Possible Solutions

1. Remove the SSH key creation from bootstrap altogether because we don't
   actually need it for anything else in bootstrap
2. We could introduce a non-interactive part to the script where we tell the
   user to hit `C-z` to copy the password to the clipboard from `pass` manually
   and then hit `fg` to resume so they can paste it when prompted.

   However, this would only work in graphical environments and not over SSH.

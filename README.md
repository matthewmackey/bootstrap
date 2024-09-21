# Bootstrap Instructions

```
# Run the following command on the remote host 1st if you are running bootstrap remotely over SSH:
export GPG_TTY=$(tty)

curl -o bootstrap.sh https://raw.githubusercontent.com/matthewmackey/bootstrap/main/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

### Note on GPG_TTY

If running this remotely, then we need to set the GPG_TTY variable or else the `gpg` utility
can't prompt us for our GPG passphrase.

You can see here for more info:

- https://stackoverflow.com/questions/51504367/gpg-agent-forwarding-inappropriate-ioctl-for-device

I don't want to use the `ssh -X` method also mentioned on this page because of comments in
the SSH man page regarding X11 Forwarding security risks (which `-X` is for).

Getting Started with gpg
------------------------

If you're unfamiliar with gpg, please read the [GNU Privacy
Handbook](http://www.gnupg.org/gph/en/manual.html) .  If you're too
lazy or impatient to do so, you can get started quickly by:

1. Installing the appropriate gpg package for your OS if you don't
already have one.

1. Running `gpg --gen-key` to create your key.

If you use this key for anything more than a few local tests, please:

1. Publish your public key so others can retrieve it.
   `gpg --keyserver pool.sks-keyservers.net --send-keys <your-new-key-id>`

1. Backup your private key.  It's irretrievable if lost or corrupted.

1. Generate a revocation certificate.  This allows you to invalidate a
key if a malicious user gains access.

1. Read the GNU Privacy Handbook above.


Motivation
==========

### Why we should sign gems

To assure the validity of any software package, you need to:

* Verify that the package has not been corrupted or maliciously
  tampered with by verifying the file's checksum.

* Verify that the checksum has not been tampered with by validating a
  digital signature of that checksum.

* Verify that the digital signature was produced by the package's
  publisher by authenticating the public key that was used to generate
  the digital signature.

If you can't do this, you can't verify the integrity of the package.

### Why we should sign gems with OpenPGP

Rubygems does currently allouw you to sign gems via X.509 certificates
generated by OpenSSL.  The code that is in place works.  But there are
several components missing that prevent end users from easily
authenticating gems.

1. Current instructions have you generate self-signed certificates.
Self-signed X.509 certificates are basically worthless.  There's no
easy way to verify that the key is legitimate.  OpenPGP certificates
are designed to be generated by you, and then signed by other people
to validate their authenticity.

2. Setting up an X.509 CA will take some significant resources and
crypto expertise.  It can't be done in a weekend.  The OpenPGP Web of
Trust allows you to incrementally build up authentication and trust
instead of having an all (Certificate Authority) or none (self-signed
certificates) level of authentication.  

3. There is no mechanism to distribute public keys.  My current work
project has 461 gems.  Going to individual author's sites for all of
these gems doesn't scale.  OpenPGP already has a dedicated pool of
servers run by volunteers at pool.sks-keyservers.net.

3. Current private key maintenance is clumsy.  Your private key isn't
encrypted.  It's a strange file in a strange location that could
easily be lost.  In gpg, all files are stored in ~/.gnupg.  Private
keys are encrypted by default.

In addition to problems with the current X.509 implementation, OpenPGP
also has the following benefits.

1. gpg has better tooling and documentation than openssl.  There are
plenty of things like Seahorse or GPA to examine your keys.  Policies
are documented and explained.

2. gpg allows the user to decide their default threat model and key
verification model.  X509 assumes you trust the powers that be.

3. The OpenPGP certificate will (optionally) be tied to the owner's
real life id, if (for example) they sign release emails, use git's
signing functionality on release tags, sign binary releases.  This
makes it easier to verify that the key isn't forged.  (See trust model
4 below.)

The way I envision it, a gem maintainer would generate and publish a
key with gpg if they didn't already have one.  He would put the key id
in the gem configuration file.  When he builds the gem, gpg kicks in
and signs it.

An end user who wants to verify the key runs a command after fetching
the gem.  If they have the key, we run gpg and verify the signature.
If not, we provide the key id so they can download it manually with
gpg.

The code to implement this should be pretty simple.

### Authenticating keys / Certificate authority

With gpg, the user can determine their trust model.

1. None.  The current model.  The user doesn't care.  They don't check
gpg sigs.  All is well.  I imagine this will still be the model used
by a strong majority of users.

2. Continuity model.  I downloaded the signing key for Ubuntu about four
releases ago.  Even though I haven't done full verification, there
haven't been any reports of problems, and the next three releases were
signed by the same key.  If the key changed and gpg couldn't verify the
next Ubuntu release, it would raise some eyebrows.  You can use the same
philosophy with gems.

3. Certificate Authority.  Similar to the way a distributed source
control system can be used as a centralized system, the OpenPGP web of
trust can be setup to act as if there's a certificate authority.

4. The user uses the OpenPGP web of trust.  To be honest, this is a
PITA.  It involves getting into the strong set by meeting people in
person and exchanging key fingerprints to make sure that there's no
man-in-the-middle attack.  And even if the user is in the strong set,
there's no guarantee the gem maintainer is.

For an example of option 4, look at the PGP Corp Global Directory[1].
You go to the website and submit your public key.  It sends you an email
that you need to reply to.  If you reply, signs your key and
publishes the information.  If another user trusts the Global Directory
key, they will now trust your key.

Technically, this is subject to a man-in-the-middle attack.  But it's
the same policy that gets used when I forget my password at something
like Amazon.  And Amazon has my credit card info.  I think the
procedure is valid against all but the most exotic attacks as long as
its limitations are known and documented.

[For conciseness' sake, I'm just going to pretend we've agreed that
rubygems.org is the Signing Authority.  It will probably be a more
beta application, at least at first.  Right now I'm more concerned
with presenting the model.]

rubygems.org could:

1. Allow gem publisher to upload a private key from their account page.

2. Upon receipt of key, send an email to the gem publisher's email
containing an encrypted token.

3. The gem publisher decrypts the token,

4. The gem publisher posts the decrypted token onto a form at the
website and submits.  This establishes the gem publisher has control of
(a) the email address, and (b) the OpenPGP key.  (Excluding a possible
mitm at the network level.)

5. rubygems.org signs the key with it's own signing key, possibly with a
6 month or 1 year expiration date.

6. The new signature is submitted to the keyservers at
pool.sks-keyservers.net, making the verification available world-wide.

Now an unrelated gem user can configure gpg to trust the rubygems
signing key.  When they download the gem from above and retrieve the gem
publisher's key, they will see that the key is valid because it's
trusted by rubygems.  If it's not trusted, it's up to User B to
investigate and determine if they trust the gem or not.

Note that the relationship between these keys isn't contained in the
gem.  It's contained on the keyservers.  If another website or mirror
provides the same gem with the same signature, it will still show up as
valid, assuming the gem user trusts the rubygems.org signing key.

### In the year 2038

Assuming all goes well, most people are signing their gems, and the
community likes the feature, we could configure a keyring for use by
gems only, similar to the way apt-get maintains its own keyring.

This keyring would automatically include the rubygems.org signing key on
installation.  When downloading a new gem, verification will happen
automatically.  If the key isn't on the gem keyring it will be
downloaded automatically.  If the key isn't trusted, the user will
receive a warning and asked if they want to continue.  If the signature
check fails, the gem will not be installed.

[1] https://keyserver.pgp.com/vkd/GetWelcomeScreen.event

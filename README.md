rubygems-openpgp
================

This gem allows cryptographic signing of ruby gems with OpenPGP
instead of the current method involving OpenSSL.  I think OpenPGP is a
much better choice than X509 certificates for verifying open source
components.

My proposal as to why we should do so, and how to add certification
infrastructure into place, follows.  Note this project doesn't attempt
to address the issue of creating a ruby gem Signing Authority.

Prerequisites
-------------

A working installation of gpg.

An OpenPGP private key is required to sign gems, but not to verify.

[Getting started with gpg.](./doc/getting-started-with-gpg.md)

Signing example
---------------

    gem build openpgp_signed_hola.gemspec
    gem sign openpgp_signed_hola-0.0.0.gem
    gem push opnepgp_signed_hola-0.0.0.gem

Verification Example
--------------------

A test gem **openpgp_signed_hola** is on rubygems.org.  To try out
this extension:

    gem fetch openpgp_signed_hola
    gem verify openpgp_signed_hola-0.0.0.gem
    gem install openpgp_signed_hola-0.0.0.gem

But That Just Failed!
---------------------

The first time you do this, the `gem verify` command will probably
fail.  This is because you don't have my public key.  To automatically
retrieve the key from the keyservers, run:

    gem verify --get-key openpgp_signed_hola-0.0.0.gem

The key will be automatically downloaded, and verification should now
succeed.

There are security implications here.  You've downloaded the key based
on the information contained in the gem itself.  If a malicious user
has tampered with the gem, they could easily provide a forged OpenPGP
key as well.  This is why your output includes the following warning:

    gpg: WARNING: This key is not certified with a trusted signature!
    gpg:          There is no indication that the signature belongs to the owner.

You still don't know if this key *really* belongs to me.  If possible,
you should verify the key signature through an out-band-channel.  This
may be the project page, a release email from the author, or some
other means.

For example, you can obtain the fingerprint on my key from [my
personal website](http://www.grant-olson.net/openpgp-key).

I've also included it right here in the README hosted on github:

    pub   2048R/E3B5806F 2010-01-11 [expires: 2012-01-04]
          Key fingerprint = A530 C31C D762 0D26 E2BA  C384 B6F6 FFD0 E3B5 806F
    uid                  Grant T. Olson (Personal email) <kgo@grant-olson.net>
    uid                  Grant T. Olson (pikimal) <grant@pikimal.com>
    sub   2048R/6A8F7CF6 2010-01-11 [expires: 2012-01-04]
    sub   2048R/A18A54D6 2010-03-01 [expires: 2012-01-04]
    sub   2048R/D53982CE 2010-08-31 [expires: 2012-01-04]

Even better would be obtaining the key fingerprint from me personally,
but this can often be impractical.

In any case, you should verify the key fingerprint listed in the
message from one of these alternate sources.  If they match, the
signature is (hopefully) valid, assuming an attacker hasn't managed to
compromise rubygems, github, and my personal website.

If the fingerprints DO NOT match, you probably want to delete the
invalid key from your keyring:

    gpg --delete-key <<KEY_ID>>

If you feel confident that the key is valid based on your external
fingerprint checks, you can make a signature on your gpg keyring.  I
would advise making a local signature unless you've validated the
fingerprint in person.  This means that you feel confident that the
key is valid, but you're not making any representations to the outside
world.  To do so, run:

    gpg --lsign <<KEY_ID>>

After this, you will no longer receive WARNINGs about untrusted
sources for any gems signed by this key/author.

Unfortunately, authentication is a hard problem.  See my proposal
below for a potential solution to provide reasonable assurances about
key validity without having to manually confirm everything.

Verifying your initial install
------------------------------

All releases of rubygems-openpgp should be signed by my key.  However,
this creates a chicken-and-egg problem the first time you download the
release.  To verify your initial download, save the following
signature and manually verify by running:

    gem fetch rubygems-openpgp
    gpg --verify saved_sig.asc rubygems-openpgp-0.2.1.gem
    gem install rubygems-openpgp-0.2.1.gem

Signature for release 0.2.1:

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG v1.4.10 (GNU/Linux)
    
    iQEcBAABAwAGBQJN5DZLAAoJEP5F5V2hilTWRT0H/0pOYJrQXeIWZHd1O/zu8Fk4
    dYlHy4Dpm3BrskJaq0EQm81BLVeHGawTPYIUr/tI3Wnmfy+pSBxpAgA7OZMkHnu2
    sHzLqU/FixMmYPMBkfZ0bDDsSgr1fAOINRCy6wlpQvlpnuMiybB7+UDboQEfaLLa
    c8kvCenhEWiI6MO3lyye7PKfgNXNbML5vGJ/WcI3HIQpAgJ8+ItB16tLnw22JlPe
    qv+IS9SlHE/0vY6HdAB3wnfuQpLXM5JZlpcErFR37dCGrvlcgetjWN84pEtm6jIO
    Jsk6YyxWu5uxE84UEc8HWzbFrb5sVstYLKW+vwqIVV76spK5EvAaKCOrMnzP/Qg=
    =Lltd
    -----END PGP SIGNATURE-----

After you've done this, you should be able to verify future releases
with the standard `gem verify ...`

In addition, all releases are tagged in git with gpg signatures, if
you need to verify a source download.

TODO: git gpg verify commands...

Motivation
----------

### Why we should sign gems with gpg

Gems are currently signed via X509 certificates generated by OpenSSL.
I don't think X509 signatures are the way to go.  I think we should use
OpenPGP signatures instead.

1. Self-signed X509 certificates are basically worthless.  There's no
easy way to verify that the key is legitimate.  OpenPGP certificates
are designed to be generated by you, and then signed by other people
to validate their authenticity.

2. Setting up an X509 CA will take some resources.  OpenPGP already
has a dedicated pool of servers run by volunteers at
pool.sks-keyservers.net.

3. The current generation policy isn't so good.  Your private key
isn't encrypted.  It's a strange file in a strange location that could
easily be lost.  In gpg, all files are stored in ~/.gnupg.  Private
keys are encrypted by default.

4. gpg has better tooling and documentation than openssl.  There are
plenty of things like Seahorse or GPA to examine your keys.  Policies
are documented and explained.

5. gpg allows the user to decide their default threat model and key
verification model.  X509 assumes you trust the powers that be.

6. The OpenPGP certificate will (optionally) be tied to the owner's
real life id, if (for example) they sign release emails, use git's
signing functionality on release tags, sign binary releases.  This
makes it easier to verify that the key isn't forged.  (See trust model
3 below.)

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

1. The current model.  The user doesn't care.  They don't check gpg
sigs.  All is well.  I imagine this will still be the model used by a
strong majority of users.

2. The user uses the OpenPGP web of trust.  To be honest, this is a
PITA.  It involves getting into the strong set by meeting people in
person and exchanging key fingerprints to make sure that there's no
man-in-the-middle attack.  And even if the user is in the strong set,
there's no guarantee the gem maintainer is.

3. Continuity model.  I downloaded the signing key for Ubuntu about four
releases ago.  Even though I haven't done full verification, there
haven't been any reports of problems, and the next three releases were
signed by the same key.  If the key changed and gpg couldn't verify the
next Ubuntu release, it would raise some eyebrows.  You can use the same
philosophy with gems.

4. Simulated CA.  Similar to the way a distributed source control system
can be used as a centralized system, the OpenPGP web of trust can be
setup to act as if there's a certificate authority.

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

Retrieving and Authenticating Keys
==================================

The first time you attempt to verify a gem, the `gem verify` command
will probably fail.  This is because you don't have the public key to
validate the signature.  Lets use my test gem to walk you through the
process.


To automatically retrieve the key from the keyservers, run:

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


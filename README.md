rubygems-openpgp
================

Software Assurance
------------------

To assure the validity of any software package, you need to:

* Verify that the package has not been corrupted or maliciously
  tampered with by verifying the file's checksum.

* Verify that the checksum has not been tampered with by validating a
  digital signature of that checksum.

* Verify that the digital signature was produced by the package's
  publisher by authenticating the public key that was used to generate
  the digital signature.

If you can't do this, you can't verify the integrity of the package.

This gem allows cryptographic signing of ruby gems with OpenPGP
instead of the current built-in signing method involving X.509.

[Read more about why we should use OpenPGP.](./doc/motivation.md)
Here's the [slides](http://bit.ly/TUtT3S) and
[video](http://vimeo.com/album/2255908/video/59297058) from a
lightning talk I did at [Pittsburgh.rb](http://pghrb.heroku.com/).
 
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

You probably don't have my public key yet.  You need my public key to
verify the digital signature.  You also want to perform some
authentication of that public key.

[Notes on retrieving and authenticating public keys.](./doc/retrieving-and-authenticating-keys.md)

Verifying your initial install
------------------------------

All versions of this gem should be signed.  But the first time you
install the package you run into a bit of a chicken-and-the-egg
problem.  You can't verify the package until you've installed a copy.
But if that copy isn't verified, if could already be compromised.

But don't worry.  You can use a stand-alone signature to verify your
initial install.  Since the stand-alone signature is on github, and
the software package is on rubygems.org, a malicious user would need
to compromise both sites to publish a compromised gem and
compromised/forged digital signature.

[Notes on verifying the initial install.](./doc/verifying-initial-install.md)


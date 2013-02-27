rubygems-openpgp
================

Information for gem users and gem developers is slowly and surely migrating
to the [rubygems-openpgp Certificate
Authority](http://rubygems-openpgp-ca.org).  You probably want to go
there unless you're interested in working on the plugin itself.


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

    gem build openpgp_signed_hola.gemspec --sign
    gem push opnepgp_signed_hola-0.0.0.gem

Verification Example
--------------------

A detailed walkthrough of verifiction is available at
[The Complete Guide to Verifying Gems with
rubygems-openpgp](http://www.rubygems-openpgp-ca.org/blog/the-complete-guide-to-verifying-gems-with-rubygems-openpgp.html)

### TLDR?

A test gem **openpgp_signed_hola** is on rubygems.org.  To try out
this extension:

    gem install openpgp_signed_hola-0.0.0.gem --verify  --trust --get-key


### But That Just Failed!

You probably don't *trust* my public key.  More information is
available at [The Complete Guide to Verifying Gems with
rubygems-openpgp](http://www.rubygems-openpgp-ca.org/blog/the-complete-guide-to-verifying-gems-with-rubygems-openpgp.html)

Verifying your initial install
------------------------------

You can verify your initial install with a detached signature.
[Here's
how.](http://www.rubygems-openpgp-ca.org/blog/the-complete-guide-to-verifying-your-initial-install.html)


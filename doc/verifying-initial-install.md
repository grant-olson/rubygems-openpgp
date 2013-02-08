Verifying the Initial Install
=============================

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


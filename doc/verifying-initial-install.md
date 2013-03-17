Verifying the Initial Install
=============================

All releases of rubygems-openpgp should be signed by my key.  However,
this creates a chicken-and-egg problem the first time you download the
release.  To verify your initial download, save the following
signature and manually verify by running:

    gem fetch rubygems-openpgp
    gpg --verify saved_sig.asc rubygems-openpgp-0.6.0.gem
    gem install rubygems-openpgp-0.6.0.gem

Signature for current release (0.6.0):

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG v2.0.17 (GNU/Linux)
    
    iQEcBAABAgAGBQJRRf0qAAoJEP5F5V2hilTWnhwIAIeCxmyiUT4C7/VPLvpwPypX
    IGrhaA3hZZzknAh2MxKx+OPiWDt7ynvSlfdbdYbkSbiKv4ho4husLrhfGV7COKws
    HImXCE4SF+Zhb2WifI7haSCRfrZ4M0z/4adalcB4GpkDRmRYuw1RI92PDLOADLSD
    u80FPfEF2ekRJqFAUU1Ayzpl8MCfl8e6uzj2CZ8CKtceApb6HZbdWA/jhvuIjXXM
    tJDAE22rugFw8ba6e9iinFHYpo9XYMG551YzR70lAqWXtxjgAM3jVDGlAXpkQGxM
    9WTas7RRYmLH1h+JvB/DFR61oZaC3gzBP1IS42KOnXywwcq/rK6/CltPf6MZtco=
    =aA4r
    -----END PGP SIGNATURE-----

After you've done this, you should be able to verify future releases
with the standard `gem verify ...`

In addition, all releases are tagged in git with gpg signatures, if
you need to verify a source download.

TODO: git gpg verify commands...

Signatures for All Releases
---------------------------

### 0.6.0

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG v2.0.17 (GNU/Linux)
    
    iQEcBAABAgAGBQJRRf0qAAoJEP5F5V2hilTWnhwIAIeCxmyiUT4C7/VPLvpwPypX
    IGrhaA3hZZzknAh2MxKx+OPiWDt7ynvSlfdbdYbkSbiKv4ho4husLrhfGV7COKws
    HImXCE4SF+Zhb2WifI7haSCRfrZ4M0z/4adalcB4GpkDRmRYuw1RI92PDLOADLSD
    u80FPfEF2ekRJqFAUU1Ayzpl8MCfl8e6uzj2CZ8CKtceApb6HZbdWA/jhvuIjXXM
    tJDAE22rugFw8ba6e9iinFHYpo9XYMG551YzR70lAqWXtxjgAM3jVDGlAXpkQGxM
    9WTas7RRYmLH1h+JvB/DFR61oZaC3gzBP1IS42KOnXywwcq/rK6/CltPf6MZtco=
    =aA4r
    -----END PGP SIGNATURE-----

### 0.5.1

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG v1.4.11 (GNU/Linux)
    
    iQEcBAABAgAGBQJRPMTkAAoJEP5F5V2hilTWuBMH/30hvYMpCP6dawq6LwufKTgB
    w+hsiII3nRshCo6yicYs8kBsT/7oSc7XZg1q3oHXQgJdal/eLBdVEOXdZ8a7zKPh
    SjvuHRSBpei3wA1DjPAvJxqjdGOX883rzDLRtP+pvyzazeO6Fj/8d/c8Y6YArEf5
    gwWdaA2s0XXdecH21yWMZPKD3x2YQEARCJJWhyngt+FW5ZHlaAwXPkhpAptzchEe
    MC8ThY4WZIPRc3+O9II93wGcNJu3T0sOg5NUzgT6vNLzCOtNLNe/hpD/QWUt/5za
    RbwqxGcP0QyNDEZQTVpLTBiiq++qyGRUb7cySTDVBqgwasal19VmVsflhTCbBt0=
    =mU3L
    -----END PGP SIGNATURE-----

### 0.5.0

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG v1.4.11 (GNU/Linux)
    
    iQEcBAABAgAGBQJRPJY3AAoJEP5F5V2hilTWVj8H/2R3Ue+4lJxbpZwu/cOodlWb
    ApflZwrhOnGHjxswL7cV7Rf15sPP9WHUvNf/n8Cuc4hHKArW7/wwdw1LP4wmrRz4
    8RxKx8kR7An9JFvs9HhrDt1BvS/j9moaKn//lZfZV7LPIEEuHEUTCNCtHkuV/oBG
    LH9tNSMs1CO1D1kkPyxc2aXZm0mRpygWrS1YskJPy7xdR2aNQk4LHJNF168m+XJH
    2l8U29QgoCpD0W4iL+6ooyY2lyVFWYhQbBd7ojVRG16Q8CxUf4+ZNey+3tgchVEP
    qBFa4M/+m2LoVdCGPOL8meFMytDR75J4VGWtGmRxjfhBeOeNVhneIQT5C6fHCfw=
    =Qxhv
    -----END PGP SIGNATURE-----

### 0.4.0

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
    
    iQEcBAABCgAGBQJRKNPSAAoJEP5F5V2hilTWMS4IAIfrL21CuSrZCof8UcrFPZds
    LvCEhBKbfE4aB4Jgf8QBc6PXrm916TU8+IcfhWVzHc98ENRui+xUVtJ1LOF7tx31
    eUcck9VqGZQ7RkI9GpX5Dcbj+0SzL3ghVgVv+UMttwwAahqT8VXvPlS6ttHjroqD
    87flVoUED/MNFeT8AfGvDp4IOJ+lQl8Y7x6JUJJv+OCOSnG6e/xtQZcMaTf9LKWW
    z6FO9iplsjbLdwCndKjbPT6bygYRmw8/mF/t3DSJb7wf4HbFjLri24TkwNVZ5o9T
    hiUjubQJuZrjVTqpaPW7ZF0iL/0xgERCz7gN6SsvIM5MIm3Hok1oZ2oVMS8fzZQ=
    =RUfl
    -----END PGP SIGNATURE-----


### 0.3.0

    -----BEGIN PGP SIGNATURE-----
    Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
    
    iQEcBAABCgAGBQJRF6YqAAoJEP5F5V2hilTWDYQH/jEDDhI6MrgMtJrjtUY7RDdN
    +MTwkTutOIZ8P35KnKen1gOrNKzrS+Pl5p7m2fa09VBv1e1v7XNsV4Rweh4jQcuP
    YDR9h0Cn4rexWj9ABC0rGVpvQrTDEJK1acTbBXI0PFs4w0m9DOT/0U5l147W+mii
    Sg7nUM3Tgvxk38d4djS3ifD+Aq6+Nm3F2hRhamTVfdaerjWJSy4Bg7HW+FaXTqyE
    dFob+Mv1PZG+VPG78zszq+4WMbhvNAUtegmsXvfl8+j9S142emw2HU2Mcs71QBo4
    /Tb6iPyaQsXAtR15Z9vO3W/bMTCyZsTq5Hwwgp01MIr+Ek+TjM6DK8wfT65sab8=
    =N+W6
    -----END PGP SIGNATURE-----

### 0.2.1

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


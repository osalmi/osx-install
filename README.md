A simple post-install script for unattended OS X installs.

## Building the installer package

* echo 'ADMINPASS="changeme"' > files/Library/Custom/postinstall.conf
* pkgbuild --identifier local.postinstall --root files postinstall.pkg

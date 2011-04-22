#!/bin/sh

REPODIR=/mnt/loggly/repo
REPONAME=loggly-production

if [ -z "$1" ] ; then
  echo "Usage: $0 <yourpackage.deb>"
  exit 1
fi

sudo -u pkgrepo \
  env GNUPGHOME=/opt/loggly/repo/gpg \
  reprepro --keepunusednewfiles --keepunreferencedfiles -Vb $REPODIR includedeb $REPONAME $@

# Temporary until we write our own (or find a) tool to manage apt repos
# that supports multiversion
sudo -u pkgrepo \
  env GNUPGHOME=/opt/loggly/repo/gpg \
  genrepo.sh
#sudo -u pkgrepo \
  #env GNUPGHOME=/opt/loggly/repo/gpg \
  #reprepro --keepunreferencedfiles -Vb $REPODIR export $REPONAME


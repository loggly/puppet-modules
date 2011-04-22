#!/bin/sh

cd /mnt/loggly/repo
export GNUPGHOME=/opt/loggly/repo/gpg

echo "Generating new repo"
RELEASE="loggly-production"
PACKAGES="dists/$RELEASE/main/binary-amd64/Packages"

echo "Generating packages list"
apt-ftparchive --db apt-ftparchive.db packages pool > $PACKAGES
gzip -c $PACKAGES > $PACKAGES.gz

echo "Generating Release file"
(
  cat dists/$RELEASE/main/binary-amd64/Release
  echo "Codename: $RELEASE"
  apt-ftparchive release dists/$RELEASE 
) > dists/$RELEASE/Release

rm -f dists/$RELEASE/Release.gpg 
echo "Signing Release file"
gpg --output dists/$RELEASE/Release.gpg -ba dists/$RELEASE/Release
echo "Done"

#!/bin/sh

REPODIR=/mnt/loggly/repo
REPONAME=loggly-production

if [ $(whoami) != "pkgrepo" ] ; then
  echo "Switching users to 'pkgrepo'"
  exec sudo -u pkgrepo $0 "$@"
fi

if [ -z "$GOT_LOCK" ] ; then
  echo "Grabbing lockfile..."
  exec flock -w 10 -x "$REPODIR/publish.lock" env GOT_LOCK=1 $0 "$@"
fi

if [ -z "$1" ] ; then
  echo "Usage: $0 <yourpackage.deb>"
  exit 1
fi

for i in $@ ; do
  package_name="$(dpkg-deb --show --showformat='${Package}\n' "$i")"
  if echo "$package_name" | grep '/^lib' ; then
    subdir=lib$(echo "$package_name" | cut -b1)
  else
    subdir=$(echo "$package_name" | cut -b1)
  fi

  dir="$REPODIR/pool/main/$subdir/$package_name"
  target="${dir}/$(basename $i)"
  echo "Target: $target"
  if [ -f "$target" ] ; then
    echo "A package with the same file name is already in this repository. Aborting copy."
    exit 1
  else
    echo "Copying $i to apt repo..."
    mkdir -p "$dir"
    cp -v "$i" "$target"
  fi
done

env GNUPGHOME=/opt/loggly/repo/gpg genrepo.sh

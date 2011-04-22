#!/bin/sh
# Recreate the reprepro db from existing debs.

REPODIR=/mnt/loggly/repo
REPONAME=loggly-production


mv $REPODIR/db $REPODIR/db.$(date +%Y.%m.%d)

find $REPODIR -name '*.deb' -type f \
  | xargs -n1 stat -c "%Y %n" \
  | sort -n \
  | awk '{$1=""; print}' \
  | xargs -n50 sudo -u pkgrepo \
      env GNUPGHOME=/opt/loggly/repo/gpg \
      reprepro --keepunusednewfiles --keepunreferencedfiles -Vb $REPODIR includedeb $REPONAME


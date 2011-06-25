# 'buildserver'

This manifest deploys our build server.

It's not fancy, but it hosts our apt repo.

The script 'publish.sh' is run like this:

    publish.sh mynewpackage.deb

It puts the package into your apt repo and rebuilds the repo.

## Apt repo details

I use a combination of apt-ftparchive + custom scripts to manage our apt repo.

I used to use reprepro, but that tool is a pile of shit. It is completely
infected with debian policies - stuff that gets in my way and enforces opinions
about things in the code. Do not want.

Publishing packages is done with 'publish.sh' and genrepo.sh manages
apt-ftparchive and gpg invocations.

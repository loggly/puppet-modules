# 'buildserver'

This manifest deploys our build server.

It's not fancy, but it hosts our apt repo.

The script 'publish.sh' is run like this:

    publish.sh mynewpackage.deb

It puts the package into your apt repo and rebuilds the repo.

## Apt repo details

I use a combination of reprepro and apt-ftparchive to manage our apt repo.

reprepro is used to publish packages to the right place. apt-ftparchive is used
to generate the metadata of which packages exist and computes their checksums.

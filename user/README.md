# User module

This module assumes ssh keys go in /etc/ssh/authorized-keys/<user>.pub - not
the defualt of $HOME/.ssh/authorized_keys

The gist of things is you add a user (typically a human) and their public key file.

Humans go in manifests/humans.pp -

    class user::humans {
      user::managed {
        "jls": ensure => present, root => true;
      }
    }

Then put the authorized_key file in files/publickeys/jls.pub

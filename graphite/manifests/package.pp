class graphite::package {
  include ::python::package::django
  include ::python::package::django::tagging
  include ::python::package::sqlite

  python::package {
    "python-whisper": ensure => latest;
    "python-carbon": ensure => latest;
    "python-graphite-web": ensure => latest;
    "python-zope.interface": ensure => latest;
    #"python-sqlite3": ensure => latest;

    # Use our own version of cairo
    "python-cairo": ensure => absent;
  }

  # We built these, not ubuntu native.
  package {
    "python-twisted": ensure => latest;
    "python-pycairo": ensure => latest;
  }
}


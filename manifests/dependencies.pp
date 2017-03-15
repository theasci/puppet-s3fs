class s3fs::dependencies {
  # List taken from http://code.google.com/p/s3fs/wiki/InstallationNotes
  $prereqs = $::operatingsystem ? {
    'CentOS' => [
      'gcc',
      'gcc-c++',
      'libstdc++-devel',
      'libcurl-devel',
      'libxml2-devel',
      'openssl-devel',
      'fuse',
      'fuse-devel',
    ],
    'Ubuntu' => [
      'build-essential',
      'libfuse-dev',
      'fuse-utils',
      'libcurl4-openssl-dev',
      'libxml2-dev',
      'mime-support ',
    ],
    default => [],
  }

  ensure_packages($prereqs)
}

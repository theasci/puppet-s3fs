class s3fs::dependencies (
  $download_dir = '/var/tmp',
  $fuse_version = '2.8.4',
) {
  # List taken from http://code.google.com/p/s3fs/wiki/InstallationNotes
  $prereqs = $::operatingsystem ? {
    CentOS => [
      'gcc',
      'gcc-c++',
      'libstdc++-devel',
      'libcurl-devel',
      'libxml2-devel',
      'openssl-devel',
    ],
    Ubuntu => [
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

  if $::operatingsystem == 'CentOS' {
    # Need to manually compile and install latest version of Fuse, because
    # Yum only has 2.8.3 and s3fs 1.74 requires >= 2.8.4
    class { 's3fs::build_fuse':
      version      => $fuse_version,
      download_dir => $download_dir,
    }
  }
}

# Class: s3fs
#
# This module installs s3fs
#
# Parameters:
#
#  [*aws_secret_access_key*] - aws secret access key
#  [*aws_access_key_id*]     - aws access key id
#  [*s3fs_package*]          - s3fs package name
#  [*s3fs_version*]          - s3fs version
#  [*credentials_file*]      - location of aws credentials file
#
# Actions:
#
# Requires:
#
#  Class['s3fs::dependencies']
#
# Sample Usage:
#
#  class { 's3fs':
#    $aws_access_key_id     => 'randomKey',
#    $aws_secret_access_key => 'randomSecret',
#  }
#

# http://code.google.com/p/s3fs/downloads/detail?name=s3fs-1.62.tar.gz&can=2&q=
class s3fs (
  $aws_secret_access_key,
  $aws_access_key_id,
  $s3fs_package          = 's3fs-fuse',
  $s3fs_version          = '1.76',
  $credentials_file      = '/etc/passwd-s3fs',
  $mounts                = {},
  $install_cache_cleaner = false,
) {
  include s3fs::dependencies

  $credentials = inline_template(
    "<%= @aws_access_key_id %>:<%= @aws_secret_access_key %>\n")
  file { 's3fs_credentials':
    ensure  => present,
    path    => $credentials_file,
    content => $credentials,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
  }

  package { $s3fs_package: ensure => $s3fs_version }

  if $install_cache_cleaner {
    file { '/usr/bin/s3fs_cache_cleaner':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0777',
      source => 'puppet:///modules/s3fs/cache_cleaner',
    }
  }

  create_resources('s3fs::mount', $mounts, {
    require => Package[$s3fs_package],
  })
}

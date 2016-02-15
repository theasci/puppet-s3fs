# Class: s3fs
#
# This module installs s3fs
#
# Parameters:
#
#  [*aws_secret_access_key*] - aws secret access key
#  [*aws_access_key_id*]     - aws access key id
#  [*package_name*]          - s3fs package name
#  [*package_ensure*]        - s3fs package "ensure" parameter
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
  $package_name          = 's3fs-fuse',
  $package_ensure        = 'latest',
  $credentials_file      = '/etc/passwd-s3fs',
  $mounts                = {},
  $default_uid           = '0',
  $default_gid           = '0',
  $default_mode          = '0660',
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

  package { $package_name: ensure => $package_ensure }

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
    require => Package[$package_name],
  })
}

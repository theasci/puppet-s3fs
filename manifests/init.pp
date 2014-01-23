# Class: s3fs
#
# This module installs s3fs
#
# Parameters:
#
#  [*ensure*]                - 'present',
#  [*s3fs_package*]          - $s3fs::params::s3fs_package,
#  [*download_dir*]          - Dir where s3fs tar.gz is downloaded
#  [*version*]               - s3fs version
#  [*download_url*]          - s3fs tar.gz download link
#  [*aws_access_key_id*]     - aws access key id
#  [*aws_secret_access_key*] - aws secret access key
#  [*credentials_file*]      - location of aws credentials file
#
# Actions:
#
# Requires:
#
#  Class['s3fs::dependencies'], Class['s3fs::params']
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
  $ensure                = 'present',
  $s3fs_package          = 's3fs',
  $download_dir          = '/var/tmp',
  $version               = '1.61',
  $fuse_version          = '2.8.4',
  $download_url          = 'http://s3fs.googlecode.com/files',
  $credentials_file      = '/etc/passwd-s3fs',
  $mounts                = {},
) {
  class { 's3fs::dependencies':
    download_dir => $download_dir,
    fuse_version => $fuse_version,
  }

  $credentials = inline_template(
    "<%= @aws_access_key_id %>:<%= @aws_secret_access_key %>\n")
  file { 's3fs_credentials':
    ensure  => $ensure,
    path    => $credentials_file,
    content => $credentials,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
  }

  Exec {
    logoutput   => false,
    timeout     => 300,
    path        => '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin',
    unless      => "which s3fs && s3fs --version | grep ${version} > /dev/null 2>&1",
    require     => Package[$s3fs::dependencies::prereqs],
  }

  $filename = "s3fs-${version}.tar.gz"
  $build_dir = "${download_dir}/s3fs-${version}"

  exec { 's3fs_tar_gz':
    command     => "wget --quiet ${download_url}/${filename}",
    cwd         => $download_dir,
    creates     => "${download_dir}/${filename}",
  }
  ->
  exec { 's3fs_extract':
    command     => "tar --no-same-owner -xzf ${filename}",
    cwd         => $download_dir,
    creates     => $build_dir,
  }
  ->
  exec { 's3fs_configure':
    command => "${build_dir}/configure --prefix=/usr",
    cwd     => $build_dir,
    creates => "${build_dir}/config.status",
  }
  ->
  exec { 's3fs_make':
    command => 'make',
    cwd     => $build_dir,
    creates => "${build_dir}/src/s3fs",
  }
  ->
  exec { 's3fs_install_and_cleanup':
    command => "make install && rm -rf ${build_dir} ${download_dir}/${filename}",
    cwd     => $build_dir,
  }

  create_resources('s3fs::mount', $mounts, {
    require => Exec['s3fs_install_and_cleanup'],
  })
}

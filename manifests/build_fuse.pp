# Build FUSE from source. Necessary for distros like CentOS that don't have
# provide a version of FUSE that meet's s3fs's minimum requirements
# (>= 2.8.4 for s3fs 1.74)
class s3fs::build_fuse (
  $version,
  $download_dir = '/var/tmp',
  $download_url_base = 'http://downloads.sourceforge.net/project/fuse/fuse-2.X',
) {
    $filename = "fuse-${version}.tar.gz"
    $download_url = "${download_url_base}/${version}/${filename}"
    $build_dir = "${download_dir}/fuse-${version}"

    Exec {
      logoutput => false,
      timeout   => 300,
      path      => '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin',
      unless    => "pkg-config --modversion fuse | grep ${version} > /dev/null 2>&1",
    }

    exec { 'fuse_tar_gz':
      command => "wget --quiet ${download_url}",
      cwd     => $download_dir,
      creates => "${download_dir}/${filename}",
    }
    ->
    exec { 'fuse_extract':
      command => "tar --no-same-owner -xzf ${filename}",
      cwd     => $download_dir,
      creates => $build_dir,
    }
    ->
    exec { 'fuse_configure':
      command => "${build_dir}/configure --prefix=/usr",
      cwd     => $build_dir,
      creates => "${build_dir}/config.status",
    }
    ->
    exec { 'fuse_make':
      command => 'make',
      cwd     => $build_dir,
      creates => "${build_dir}/src/fuse",
    }
    ->
    exec { 'fuse_install_and_cleanup':
      command => "make install && rm -rf ${build_dir} ${download_dir}/${filename}",
      cwd     => $build_dir,
    }
    ->
    exec { 'fuse_ldconfig': command => 'ldconfig' }
}

# Class: s3fs::mount
#
# This module installs s3fs
# ## S3FS
#  s3fs::mount {'Testvgh':
#    bucket      => 'testvgh',
#    mount_point => '/srv/testvgh2',
#    default_acl => 'public-read',
#  }
#
define s3fs::mount (
  $bucket,
  $mount_point,
  $ensure      = 'present',
  $default_acl = 'private',
  $uid         = '0',
  $gid         = '0',
  $mode        = '0660',
  $atboot      = true,
  $fstype      = 'fuse',
  $remounts    = false,
  $cache       = '/mnt/aws_s3_cache',
  $group       = 'root',
  $owner       = 'root',
) {

  include s3fs
  Class['s3fs'] -> S3fs::Mount[$name]

  $options = "gid=$gid,uid=$uid,default_acl=${default_acl},use_cache=${cache}"
  $device = "s3fs#${bucket}"

  case $ensure {
    present, defined, unmounted, mounted: {
      $ensure_mount = 'mounted'
      $ensure_dir = 'directory'
    }
    absent: {
      $ensure_mount = 'absent'
      $ensure_dir = 'absent'
    }
    default: {
      fail("Not a valid ensure value: ${ensure}")
    }
  }

  File[$mount_point] -> Mount[$mount_point]

  file { $mount_point:
    ensure  => $ensure_dir,
    force   => true,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }

  mount{ $mount_point:
    ensure   => $ensure_mount,
    atboot   => $atboot,
    device   => $device,
    fstype   => $fstype,
    options  => $options,
    remounts => $remounts,
  }

}

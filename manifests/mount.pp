# Class: s3fs::mount
#
# This module installs s3fs
# ## S3FS
#  s3fs::mount {'testvgh':
#    bucket      => 'testvgh',
#    mount_point => '/srv/testvgh2',
#    default_acl => 'public-read',
#  }
#
define s3fs::mount (
  $mount_point,
  $bucket              = $name,
  $ensure              = 'present',
  $default_acl         = 'private',
  $uid                 = '0',
  $gid                 = '0',
  $mode                = '0660',
  $atboot              = true,
  $remounts            = false,
  $use_cache           = '',
  $max_stat_cache_size = undef,
  $perm_recurse        = false,
  $stat_cache_expire   = undef,
  $noobj_cache         = false,
  $url                 = 'http://s3.amazonaws.com',
) {
  include s3fs

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

  $options = inline_template(
    'allow_other,',
    'gid=<%= @gid %>,',
    'uid=<%= @uid %>,',
    'default_acl=<%= @default_acl %>,',
    'url=<%= @url %>',
    '<% if @use_cache %>,use_cache=<%= @use_cache %><% end %>',
    '<% if @stat_cache_expire %>,stat_cache_expire=<%= @stat_cache_expire %><% end %>',
    '<% if @noobj_cache %>,enable_noobj_cache<% end %>',
    '<% if @max_stat_cache_size %>,max_stat_cache_size=<%= @max_stat_cache_size %><% end %>'
  )

  file { $mount_point:
    ensure  => $ensure_dir,
    recurse => $perm_recurse,
    force   => true,
    owner   => $uid,
    group   => $gid,
    mode    => $mode,
  }
  ->
  mount { $mount_point:
    ensure   => $ensure_mount,
    atboot   => $atboot,
    device   => "s3fs#${bucket}",
    fstype   => 'fuse',
    options  => $options,
    remounts => $remounts,
  }

}

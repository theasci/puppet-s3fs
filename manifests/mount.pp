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
  $default_acl         = undef,
  $retries             = undef,
  $use_cache           = undef,
  $del_cache           = false,
  $use_rrs             = false,
  $use_sse             = false,
  $public_bucket       = undef,
  $passwd_file         = undef,
  $ahbe_conf           = undef,
  $connect_timeout     = undef,
  $readwrite_timeout   = undef,
  $max_stat_cache_size = undef,
  $stat_cache_expire   = undef,
  $noobj_cache         = false,
  $nosscache           = false,
  $multireq_max        = undef,
  $parallel_count      = undef,
  $fd_page_size        = undef,
  $url                 = undef,
  $nomultipart         = false,
  $enable_content_md5  = false,
  $iam_role            = undef,
  $noxmlns             = false,
  $nocopyapi           = false,
  $norenameapi         = false,

  $uid                 = $::s3fs::default_uid,
  $gid                 = $::s3fs::default_gid,
  $mode                = $::s3fs::default_mode,
  $umask               = $::s3fs::default_umask,
  $read_only           = false,
  $atboot              = true,
  $remounts            = false,
  $perm_recurse        = false,
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
    '_netdev,',
    'allow_other,',
    'gid=<%= @gid %>,',
    'uid=<%= @uid %>,',
    '<% if @umask %>,umask=<%= @umask %><% end %>',
    '<% if @read_only %>,ro<% end %>',
    '<% if @default_acl %>,default_acl=<%= @default_acl%><% end %>',
    '<% if @retries %>,retries=<%= @retries%><% end %>',
    '<% if @use_cache %>,use_cache=<%= @use_cache %><% end %>',
    '<% if @del_cache %>,del_cache<% end %>',
    '<% if @use_rrs %>,use_rrs<% end %>',
    '<% if @use_sse %>,use_sse<% end %>',
    '<% if @public_bucket %>,public_bucket=<%= @public_bucket %><% end %>',
    '<% if @passwd_file %>,passwd_file=<%= @passwd_file %><% end %>',
    '<% if @ahbe_conf %>,ahbe_conf=<%= @ahbe_conf %><% end %>',
    '<% if @connect_timeout %>,connect_timeout=<%= @connect_timeout %><% end %>',
    '<% if @readwrite_timeout %>,readwrite_timeout=<%= @readwrite_timeout %><% end %>',
    '<% if @max_stat_cache_size %>,max_stat_cache_size=<%= @max_stat_cache_size %><% end %>',
    '<% if @stat_cache_expire %>,stat_cache_expire=<%= @stat_cache_expire %><% end %>',
    '<% if @noobj_cache %>,enable_noobj_cache<% end %>',
    '<% if @nodnscache %>,nodnscache<% end %>',
    '<% if @nosscache %>,nosscache<% end %>',
    '<% if @multireq_max %>,multireq_max=<%= @multireq_max %><% end %>',
    '<% if @parallel_count %>,parallel_count=<%= @parallel_count %><% end %>',
    '<% if @fd_page_size %>,fd_page_size=<%= @fd_page_size %><% end %>',
    '<% if @url %>,url=<%= @url %><% end %>',
    '<% if @nomultipart %>,nomultipart<% end %>',
    '<% if @enable_content_md5 %>,enable_content_md5<% end %>',
    '<% if @iam_role %>,iam_role=<%= @iam_role %><% end %>',
    '<% if @noxmlns %>,noxmlns<% end %>',
    '<% if @nocopyapi %>,nocopyapi<% end %>',
    '<% if @norenameapi %>,norenameapi<% end %>'
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

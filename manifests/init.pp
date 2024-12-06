# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lidarr
class lidarr (
  Optional[String]  $ensure,
  Optional[String]  $lidarr_lib_dir,
  Optional[String]  $lidarr_opt_dir,
  Optional[String]  $lidarr_user,
  Optional[String]  $lidarr_media_group,
  Optional[String]  $systemd_after,
  Optional[String]  $systemd_wantedby,
  Optional[String]  $systemd_type,
  Optional[Integer] $systemd_timeout_stop_sec,
  Optional[String]  $systemd_killmode,
  Optional[String]  $systemd_restart,
  Enum['x64', 'arm', 'arm64'] $os_architecture,
) {
  user { $lidarr_user:
    name   => $lidarr_user,
    groups => [$lidarr_media_group],
  }

  $download_uri = "https://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${os_architecture}"
  archive { $lidarr_opt_dir:
    ensure       => 'present',
    source       => $download_uri,
    user         => $lidarr_user,
    group        => $lidarr_media_group,
    extract      => true,
    extract_path => $lidarr_opt_dir,
  }

  file { '/etc/systemd/system/lidarr.service':
    ensure  => file,
    content => epp('lidarr/lidarr.service.epp', {
        'systemd_description'      => $systemd_description,
        'systemd_after'            => $systemd_after,
        'systemd_user'             => $lidarr_user,
        'systemd_group'            => $lidarr_media_group,
        'systemd_wantedby'         => $systemd_wantedby,
        'systemd_type'             => $systemd_type,
        'lidarr_opt_dir'           => $lidarr_opt_dir,
        'lidarr_lib_dir'           => $lidarr_lib_dir,
        'systemd_timeout_stop_sec' => $systemd_timeout_stop_sec,
        'systemd_killmode'         => $systemd_killmode,
        'systemd_restart'          => $systemd_restart,
    }),
  }

  service { 'lidarr':
    ensure => 'running',
    enable => true,
  }

  package { ['curl', 'mediainfo', 'sqlite', 'libchromaprint']:
    ensure => 'present',
  }
}

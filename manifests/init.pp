# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lidarr
class lidarr (
  Optional[String]  $ensure,
  Optional[String]  $lidarr_version,
  Optional[String]  $lidarr_lib_dir,
  Optional[String]  $lidarr_opt_dir,
  Optional[String]  $lidarr_user,
  Optional[String]  $lidarr_media_group,
  Optional[Integer] $lidarr_port,
  Optional[String]  $systemd_after,
  Optional[String]  $systemd_wantedby,
  Optional[String]  $systemd_type,
  Optional[Integer] $systemd_timeout_stop_sec,
  Optional[String]  $systemd_killmode,
  Optional[String]  $systemd_restart,
  Enum['x64', 'arm', 'arm64'] $os_architecture,
) {
  group { $lidarr_media_group:
    name => $lidarr_media_group,
  }

  user { $lidarr_user:
    name   => $lidarr_user,
    groups => [$lidarr_media_group],
  }

  file { $lidarr_opt_dir:
    ensure  => directory,
    owner   => $lidarr_user,
    group   => $lidarr_media_group,
    recurse => true,
  }

  file { $lidarr_lib_dir:
    ensure  => directory,
    owner   => $lidarr_user,
    group   => $lidarr_media_group,
    recurse => true,
  }
  $archive_name = "Lidarr.master.${lidarr_version}.linux-core-${os_architecture}.tar.gz"
  $download_uri = "https://github.com/Lidarr/Lidarr/releases/download/v${lidarr_version}/${archive_name}"
  archive { "${lidarr_opt_dir}/${archive_name}":
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

  # Enable port in firewall
  firewalld_port { 'Open port for lidarr to the public':
    ensure   => present,
    zone     => 'public',
    port     => $lidarr_port,
    protocol => 'tcp',
  }
}

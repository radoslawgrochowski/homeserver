{ config, ... }:
{
  # Open firewall for Palworld server (local network access)
  networking.firewall.allowedUDPPorts = [ 8211 ];

  age.secrets.palworld-environment.file = ../secrets/palworld-environment.age;

  systemd.tmpfiles.rules = [
    "d /tank/palworld 0750 1001 docker -"
  ];

  virtualisation.oci-containers.containers.palworld = {
    image = "thijsvanloef/palworld-server-docker@sha256:50aa77c95bab2a4ff7062b6f74daa023e081efc86dbbdcf2006c0eea4e7ae3b4";
    autoStart = true;

    extraOptions = [
      "--network=host"
    ];

    environment = {
      PUID = "1001";
      PGID = "131";
      TZ = config.time.timeZone;
      PORT = "8211";
      PLAYERS = "3";
      SERVER_NAME = "Nimbus Palworld";
      SERVER_DESCRIPTION = "A Palworld server running on Nimbus";
      COMMUNITY = "false";
      MULTITHREADING = "true";
      RCON_ENABLED = "true";
      UPDATE_ON_BOOT = "true";
      BACKUP_ENABLED = "true";
      BACKUP_CRON_EXPRESSION = "0 2 * * *";
      AUTO_UPDATE_ENABLED = "false";
      AUTO_REBOOT_ENABLED = "false";
    };

    environmentFiles = [
      config.age.secrets.palworld-environment.path
    ];

    volumes = [
      "/tank/palworld:/palworld/"
    ];
  };
}

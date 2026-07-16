{ config, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  networking.firewall.allowedUDPPorts = [ 8211 ];

  age.secrets.palworld-environment.file = ../secrets/palworld-environment.age;

  systemd.tmpfiles.rules = [
    "d /tank/palworld 0750 1001 docker -"
  ];

  virtualisation.oci-containers.containers.palworld = {
    image = "thijsvanloef/palworld-server-docker@sha256:6c2364a32895cddacf0671d755a8c96a392bae19fa70f5e841747cf2d4abc2bb";
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
      UPDATE_ON_BOOT = "true";
      BACKUP_ENABLED = "true";
      BACKUP_CRON_EXPRESSION = "0 2 * * *";
      AUTO_UPDATE_ENABLED = "true";
      AUTO_REBOOT_ENABLED = "true";
      # Decrease default egg hatching time to 3h (default 72h)
      PAL_EGG_DEFAULT_HATCHING_TIME = "3.000000";
    };

    environmentFiles = [
      config.age.secrets.palworld-environment.path
    ];

    volumes = [
      "/tank/palworld:/palworld/"
    ];
  };
}

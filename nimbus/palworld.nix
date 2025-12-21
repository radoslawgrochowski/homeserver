{ config, ... }:
{
  # Open firewall for Palworld server (local network access)
  networking.firewall.allowedUDPPorts = [ 8211 ];

  age.secrets.palworld-environment.file = ../secrets/palworld-environment.age;

  systemd.tmpfiles.rules = [
    "d /tank/palworld 0750 1001 docker -"
  ];

  virtualisation.oci-containers.containers.palworld = {
    image = "thijsvanloef/palworld-server-docker:23bf8b2a4918e96fad748a9b37afbbbef3651d75f4e4ee04dca59bf3b4f1df89";
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
      BACKUP_CRON_EXPRESSION = "0 2 * * *"; # Daily backup at 2 AM
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

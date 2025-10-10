{ ... }:
{
  age.secrets.nextcloud-admin-password = {
    file = ../secrets/nextcloud-admin-password.age;
    owner = "nextcloud";
  };
  age.secrets.radarr-api-key.file = ../secrets/radarr-api-key.age;
  age.secrets.restic-env.file = ../secrets/restic-env.age;
  age.secrets.restic-password.file = ../secrets/restic-password.age;
  age.secrets.restic-repository.file = ../secrets/restic-repository.age;
  age.secrets.sonarr-api-key.file = ../secrets/sonarr-api-key.age;
  age.secrets.tailscale.file = ../secrets/tailscale.age;
  age.secrets.ddns-config = {
    file = ../secrets/ddns-config.age;
    # todo make this declarative
    owner = "ddns";
    group = "ddns";
    mode = "0400";
  };
}

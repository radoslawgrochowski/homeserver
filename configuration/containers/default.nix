{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /data/docker 0750 root root -"
  ];

  users.users.nimbus.extraGroups = [ "docker" ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # rootless = {
    #   enable = false;
    # };

    # daemon.settings = {
    #   experimental = true;
    # };
  };
}

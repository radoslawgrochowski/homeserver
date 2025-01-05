{ config, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
    authKeyFile = config.age.secrets.tailscale.path;
    extraSetFlags = [ "--advertise-exit-node" ];
  };
}

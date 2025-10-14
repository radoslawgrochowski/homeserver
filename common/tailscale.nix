{ config, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
    authKeyFile = config.age.secrets.tailscale.path;
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.0.0/24"
      "--accept-routes"
    ];
  };
  age.secrets.tailscale.file = ../secrets/tailscale.age;
}

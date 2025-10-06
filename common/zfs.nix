{ pkgs, ... }:
{
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  services.prometheus.exporters.zfs = {
    enable = true;
    port = 9134;
  };

  networking.firewall.allowedTCPPorts = [ 9134 ];

  environment.systemPackages = with pkgs; [
    zfs
    sanoid
    mbuffer
    pv
  ];
}

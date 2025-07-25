{ pkgs, ... }: {
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  environment.systemPackages = with pkgs; [
    zfs
  ];
}

{ pkgs, ... }: {
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
  environment.systemPackages = with pkgs; [
    zfs
    sanoid
    mbuffer
    pv
  ];
}

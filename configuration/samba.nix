{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "d /share 774 root share - -"
    "d /share/media 774 media share - -"
  ];

  services.samba = {
    enable = true;
    package = pkgs.samba4Full;
    openFirewall = true;
    shares.media = {
      path = "/share/media";
      writable = true;
      browseable = true;
    };

    extraConfig = '' 
      # Security
      server smb encrypt = required
      client ipc max protocol = SMB3
      client ipc min protocol = SMB2_10
      client max protocol = SMB3
      client min protocol = SMB2_10
      server max protocol = SMB3
      server min protocol = SMB2_10
   '';
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    publish.enable = true;
    publish.addresses = true;
    nssmdns4 = true;
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}

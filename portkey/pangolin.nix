{ config, inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/pangolin.nix"
  ];

  disabledModules = [
    "services/networking/pangolin.nix"
  ];

  networking.firewall.allowedUDPPorts = [ 21820 ];

  services.pangolin = {
    enable = true;
    dashboardDomain = "pangolin.fard.pl";
    baseDomain = "fard.pl";
    openFirewall = true;
    environmentFile = config.age.secrets.pangolin-environment.path;
    settings = {
      flags = {
        disable_signup_without_invite = true;
        require_email_verification = false;
        allow_raw_resources = false;
        disable_user_create_org = true;
      };
    };
  };

  systemd.tmpfiles.settings."10-pangolin-next-cache" = {
    "/var/lib/pangolin/.next/cache" = {
      d = {
        mode = "0770";
        user = "pangolin";
        group = "fossorial";
      };
    };
  };
}

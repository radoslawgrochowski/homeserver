{ config, inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/newt.nix"
  ];

  disabledModules = [
    "services/networking/newt.nix"
  ];

  services.newt = {
    enable = true;
    environmentFile = config.age.secrets.newt-token.path;
    blueprint = {
      public-resources = {
        jellyfin = {
          name = "Jellyfin";
          protocol = "http";
          full-domain = "jellyfin.fard.pl";
          auth = {
            sso-enabled = true;
          };
          targets = [
            {
              hostname = "127.0.0.1";
              port = 8096;
              method = "http";
            }
          ];
        };
      };
    };
  };
}

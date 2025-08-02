({ inputs, ... }: {
  nix = {
    channel.enable = false;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [
        "https://cache.nixos.org"
        "https://radoslawgrochowski-homeserver.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "radoslawgrochowski-homeserver.cachix.org-1:IUdvjxx3+DE0HQC2sxfrh0WWi9UlZBUGgi0CJz4K3DI="
      ];
    };
    gc.automatic = true;
  };
})

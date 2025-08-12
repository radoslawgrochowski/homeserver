{
  description = "Homeserver configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = inputs@{ self, nixpkgs, flake-utils, agenix, nixpkgs-unstable }:
    let
      commonModules = [
        ({ overlays, ... }: { nixpkgs.overlays = (nixpkgs.lib.attrValues (import ./overlays.nix { inherit inputs; })); })
        agenix.nixosModules.default
        ./common
      ];
    in
    {
      nixosConfigurations.nimbus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./nimbus ];
        specialArgs = {
          inherit inputs;
        };
      };
      nixosConfigurations.fawkes = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./fawkes ];
        specialArgs = {
          inherit inputs;
        };
      };
    } // flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              just
              agenix.packages."${system}".default
            ];
          };
        });

  nixConfig = {
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
}

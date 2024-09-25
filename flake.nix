{
  description = "Stratus Homeserver configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    nixosConfigurations.stratus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration ];
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
          ];
        };
      });
}

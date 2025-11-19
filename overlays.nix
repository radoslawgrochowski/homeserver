{ inputs, ... }:
{
  nixpkgsCustom = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
    };
  };
  fosrl = (
    final: prev: {
      inherit (inputs.nixpkgs-unstable.legacyPackages.${final.system})
        fosrl-gerbil
        fosrl-pangolin
        fosrl-newt
        ;
    }
  );
  lib = (
    final: prev: {
      lib = prev.lib.extend (
        libfinal: libprev: {
          cli = (libprev.cli or { }) // {
            toCommandLineShellGNU = inputs.nixpkgs-unstable.lib.cli.toCommandLineShellGNU;
          };
        }
      );
    }
  );
}

{ inputs, ... }:
{
  nixpkgsCustom = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
    };
  };
  pangolin = final: prev: {
    fosrl-pangolin = final.unstable.fosrl-pangolin;
    fosrl-newt = final.unstable.fosrl-newt;
  };
}

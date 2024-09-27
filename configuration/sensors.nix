{ pkgs, ... }: {
  # https://discourse.nixos.org/t/best-way-to-handle-boot-extramodulepackages-kernel-module-conflict/30729/4
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  boot.kernelModules = [ "coretemp" "it87" ];
  boot.extraModprobeConfig = ''
    options it87 force_id=0x8628
  '';

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
}

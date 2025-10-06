# based on https://github.com/azuwis/nix-config/blob/6d0d231d7adde865d0a8caf2cc22e6964d559c30/pkgs/by-name/gr/gree/package.nix

{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  owner = "RobHofmann";
  domain = "gree";
  version = "2.25.5";

  src = fetchFromGitHub {
    owner = "RobHofmann";
    repo = "HomeAssistant-GreeClimateComponent";
    rev = version;
    hash = "sha256-zo4FgYjHP+0nLdmwBpwJuqW0yvUw1rKhlZICDKXnbjY=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [
    pycryptodome
    aiofiles
  ];

  dontBuild = true;

  passthru.enable = false;
  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Custom Gree climate component written in Python3 for Home Assistant. Controls AC's supporting the Gree protocol.";
    homepage = "https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
    license = licenses.gpl3;
  };
}

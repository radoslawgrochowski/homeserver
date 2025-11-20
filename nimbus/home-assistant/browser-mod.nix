{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "thomasloven";
  domain = "browser_mod";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "hass-browser_mod";
    rev = "v${version}";
    hash = "sha256-Q2vmHR2oYKybdHTeLibQW2pd1z5qsIWbMSi3gZFctb4=";
  };

  dontBuild = true;

  passthru.enable = false;

  meta = with lib; {
    description = "A Home Assistant integration to turn your browser into a controllable entity and media player";
    homepage = "https://github.com/thomasloven/hass-browser_mod";
    license = licenses.mit;
    changelog = "https://github.com/thomasloven/hass-browser_mod/releases/tag/v${version}";
  };
}

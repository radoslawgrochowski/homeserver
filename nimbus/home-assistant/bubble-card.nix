{
  lib,
  stdenv,
  pkgs,
}:
stdenv.mkDerivation rec {
  pname = "bubble-card";
  version = "unstable-2025-09-28";

  dontBuild = true;

  src = pkgs.fetchFromGitHub {
    owner = "Clooos";
    repo = "Bubble-Card";
    rev = "c0f614b1b49db3e9da6fb3694a8b8b67c20ea0d0";
    sha256 = "04bhixxxpry7bznx3dl93qh7s4q7pqw88as5fqj4dmp2bmd113p3";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/bubble-card.js $out
    install -m0644 dist/bubble-pop-up-fix.js $out

    runHook postInstall
  '';

  meta = with lib; {
    changelog = "https://github.com/Clooos/bubble-card/releases/tag/v${version}";
    description = "Bubble Card is a minimalist card collection for Home Assistant with a nice pop-up touch.";
    homepage = "https://github.com/Clooos/Bubble-Card";
    license = licenses.mit;
  };
}

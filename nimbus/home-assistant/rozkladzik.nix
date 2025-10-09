{
  buildHomeAssistantComponent,
  home-assistant,
  pkgs,
}:

buildHomeAssistantComponent {
  version = "unstable-2025-04-05";
  owner = "PiotrMachowski";
  domain = "rozkladzik";

  propagatedBuildInputs = with home-assistant.python.pkgs; [
    requests
  ];

  src = pkgs.fetchFromGitHub {
    owner = "PiotrMachowski";
    repo = "Home-Assistant-custom-components-Rozkladzik";
    rev = "b487ff6f767785467162383600e05c98088432b1";
    sha256 = "19h75kk2pl3mqmcdg3la101iwzza9i4v8jjh61n16yj08x2ginb5";
  };

  meta = {
    description = "Home Assistant Rozkladzik integration";
  };
}

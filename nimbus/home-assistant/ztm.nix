{
  buildHomeAssistantComponent,
  home-assistant,
  pkgs,
}:

buildHomeAssistantComponent {
  version = "unstable-2024-12-15";
  owner = "peetereczek";
  domain = "ztm";

  propagatedBuildInputs = with home-assistant.python.pkgs; [
  ];

  src = pkgs.fetchFromGitHub {
    owner = "peetereczek";
    repo = "ztm";
    rev = "5b246a64ea84a20136bb52eaf74a6a03a4f88891";
    sha256 = "1ml7mj1hmynkh409bs3hhjdygjzb738s2x7mmf5asan5j4vbxkmm";
  };

  meta = {
    description = "Home Assistant ZTM integration";
  };
}

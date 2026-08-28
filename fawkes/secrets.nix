{ ... }:
{
  age.secrets.tailscale.file = ../secrets/tailscale.age;
  age.secrets.wifi-passwords = {
    file = ../secrets/wifi-passwords.age;
    owner = "wpa_supplicant";
    group = "wpa_supplicant";
    mode = "0400";
  };
}

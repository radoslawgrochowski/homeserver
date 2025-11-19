{ pkgs, config, ... }:
{

  age.secrets.pangolin-env.file = ../secrets/pangolin-env.age;
  services.pangolin = {
    enable = true;
    # package = pkgs.unstable.fosrl-pangolin;
    baseDomain = "fard.pl";
    dashboardDomain = "portkey.fard.pl";
    letsEncryptEmail = "rg@fard.pl";
    environmentFile = config.age.secrets.pangolin-env.path;
    settings = {
      flags = {
        disable_signup_without_invite = true;
        disable_user_create_org = true;
      };
    };
    openFirewall = true;
  };
}

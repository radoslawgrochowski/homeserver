{ ... }:
{
  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "$y$j9T$Fskkkn21YLU7.K2ZVkq8I1$di8IyJIdLcJGMqAfTY/daHkXB87UxL9lQspyBXwCsF4";
      };
      stratus = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "$y$j9T$hd7vUWgAvLubXpUksgoKH.$BzY.rlf.HfvGlzvq11sCNJB.5BdD.ZBSy/dHPVvQ49A";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFHfIr8ovAQXCRcDCsIeGHXF5BKi5S9kZ88WxkMKG6M rg@fard.pl"
        ];
      };
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "stratus" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.settings.trusted-users = [ "root" "stratus" ];
}
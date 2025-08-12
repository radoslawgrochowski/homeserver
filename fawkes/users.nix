{ ... }:
{
  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "$y$j9T$i0UJaA.Z2pHVDJeLqO8DJ0$C.RMrymu9ZZqo2bwI.0/dxHf8jQ1p9xbCKDcC/Jlq43";
      };

      fawkes = {
        isNormalUser = true;
        extraGroups = [ "wheel" "tank" ];
        hashedPassword = "$y$j9T$eGyvfTniP/7pBUWxzdyde.$eRZJHycdeyB7.MN1wBYQ8FqNhfWslGTrRsei/IwrRdA";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFHfIr8ovAQXCRcDCsIeGHXF5BKi5S9kZ88WxkMKG6M rg@fard.pl"
        ];
      };
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "fawkes" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.settings.trusted-users = [ "root" "fawkes" ];
}

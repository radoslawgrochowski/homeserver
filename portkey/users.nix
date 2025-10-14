{ ... }:
{
  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "$6$AIuAfL5JBo0NnpJc$1JXM8y34FL46U8duTEvLKKEjAKhvaDpPQLmnYKYboC5U9Li.3cfEeBWqN1DUnPiuw0FePhd6hjb.ySOYj7CFe1";
      };

      portkey = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "tank"
        ];
        hashedPassword = "$6$1LAjBrS6xwvUHCle$vibZg.m3a5Ubv993vS7gEo7o/PkbezSi1RUpADlzIuX6347fwdiumQSGMQ1KqpqgP.nSz/.CiUdMf/Q1/BTRB1";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFHfIr8ovAQXCRcDCsIeGHXF5BKi5S9kZ88WxkMKG6M rg@fard.pl"
        ];
      };
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "portkey" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.settings.trusted-users = [
    "root"
    "portkey"
  ];
}

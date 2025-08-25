let
  radoslawgrochowski-wsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFHfIr8ovAQXCRcDCsIeGHXF5BKi5S9kZ88WxkMKG6M rg@fard.pl";
  nimbus = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkty0jQM0fizbNNQ/vwfbPJsovdfOeA7WVAzflVlX7CCXWqkKs8q+VGLcOTIMS9SbZ4hEz0zwfoqCKXBNUdPo+tSAY1Z5nXry/byI88un/+VJfxsD+YYvujhqaMO/tTx0AjnhRcMmUa1g3/udL3N+BFDkIyiuw/BnV6Sqae2G0Pi7zwZm1KaqYKU0SbTa5OuuksY6X1v0DKGpQ9DVrSj0BCZ8oamR17ZzIQjE3vuCvR7HRdmc6ExZfZEa5mnPeAt34Oc3qP6o5g4BTgpaUSgMAD4sCETH69xq0sMMTASVhndCVkjQ8YLvjR7ad8QzZ49wD3InoBFtU7TEr2uDYNNF1BU5YOPDBLkmMiD3Du+PEdS5cOGZe0R8wFTjA/CtyYXnO73vqT+qVlMUyGW0IAq+6gKCn/CCffDZh9hXxGFTHbfC77ikRAyeiXdRbM+mO0JACiLWK5qaY9Mr2lOe1C6acerlkphEcJv34gtrTZ7BsVx1Y/Ebc/lMicKvgH+5KQ7wLq86qAu6jUNVJ+z5A7cT/mkBlYZXINpWlhftvVWZQQJi9ceZc8+aPvr7w2J5SQ4ndm2k0ZNv1Ow/hJlEtOLxg2r0weCqOCRvN3dGcob09EQLNveNX6FxL9RPTFr0H/wOTmT8VQgE0JQ8h2nrCtjF7lVP4u35kUe0TL1a5oR7VQQ==";
  fawkes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICi5oQZI2Py3n5KNZqB7v26A3z3leFop6TVMvnugQJGN root@nixos";
  home = [ radoslawgrochowski-wsl nimbus ];
  all = home ++ [ fawkes ];
in
{
  "nextcloud-admin-password.age".publicKeys = home;
  "radarr-api-key.age".publicKeys = home;
  "restic-env.age".publicKeys = home;
  "restic-password.age".publicKeys = home;
  "restic-repository.age".publicKeys = home;
  "sonarr-api-key.age".publicKeys = home;
  "tailscale.age".publicKeys = all;
  "ddns-config.age".publicKeys = home;
}

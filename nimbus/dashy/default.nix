{ ... }:
let
  nginxSettings = {
    locations."/" = {
      extraConfig = ''
        proxy_pass http://localhost:8085;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
in
{
  virtualisation.oci-containers.containers = {
    dashy = {
      image = "lissy93/dashy:release-3.1.1";
      ports = [ "8085:8080" ];
      volumes = [
        "${./conf.yml}:/app/user-data/conf.yml"
      ];
    };
  };

  services.nginx.virtualHosts."nimbus" = nginxSettings;
  services.nginx.virtualHosts."nimbus.fard.pl" = nginxSettings;
  services.nginx.virtualHosts."nimbus.local" = nginxSettings;
}

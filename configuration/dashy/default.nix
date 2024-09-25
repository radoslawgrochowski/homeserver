{ ... }:
{
  virtualisation.oci-containers.containers = {
    dashy = {
      image = "lissy93/dashy:release-3.1.1";
      ports = [ "8080:8080" ];
      volumes = [
        "${./conf.yml}:/app/user-data/conf.yml"
      ];
    };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."nimbus.local" = {
    locations."/" = {
      extraConfig = ''
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}

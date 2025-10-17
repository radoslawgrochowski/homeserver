{ pkgs, ... }:
let
  domain = "portkey.fard.pl";
  acmeEmail = "rg@fard.pl";
  serverSecret = "BVTHgFzC+PVCNLIqCtrDtyXCd4BvjAQ8Xu2+UQ+x6Vg=";

  pangolinConfig = pkgs.writeText "config.yml" ''
    app:
      dashboard_url: "https://${domain}"
      log_level: "info"

    domains:
      portkey:
        base_domain: "${domain}"
        cert_resolver: "letsencrypt"

    server:
      external_port: 3000
      internal_port: 3001
      next_port: 3002
      internal_hostname: "pangolin"
      secret: "${serverSecret}"
      trust_proxy: 1
      dashboard_session_length_hours: 720
      resource_session_length_hours: 720

    gerbil:
      base_endpoint: "${domain}"
      start_port: 51820

    traefik:
      http_entrypoint: "web"
      https_entrypoint: "websecure"
      cert_resolver: "letsencrypt"
      certificates_path: "/var/certificates"
      dynamic_cert_config_path: "/var/dynamic/cert_config.yml"
      dynamic_router_config_path: "/var/dynamic/router_config.yml"
      file_mode: false

    flags:
      require_email_verification: false
      disable_signup_without_invite: true
      disable_user_create_org: true
  '';

  traefikConfig = pkgs.writeText "traefik_config.yml" ''
    api:
      insecure: true
      dashboard: true

    providers:
      http:
        endpoint: "http://pangolin:3001/api/v1/traefik-config"
        pollInterval: "5s"
      file:
        filename: "/etc/traefik/dynamic_config.yml"

    experimental:
      plugins:
        badger:
          moduleName: "github.com/fosrl/badger"
          version: "v1.2.0"

    log:
      level: "INFO"
      format: "common"

    certificatesResolvers:
      letsencrypt:
        acme:
          httpChallenge:
            entryPoint: web
          email: ${acmeEmail}
          storage: "/letsencrypt/acme.json"
          caServer: "https://acme-v02.api.letsencrypt.org/directory"

    entryPoints:
      web:
        address: ":80"
      websecure:
        address: ":443"
        transport:
          respondingTimeouts:
            readTimeout: "30m"
        http:
          tls:
            certResolver: "letsencrypt"

    serversTransport:
      insecureSkipVerify: true

    ping:
      entryPoint: "web"
  '';

  traefikDynamicConfig = pkgs.writeText "dynamic_config.yml" ''
    http:
      middlewares:
        redirect-to-https:
          redirectScheme:
            scheme: https

      routers:
        main-app-router-redirect:
          rule: "Host(`${domain}`)"
          service: next-service
          entryPoints:
            - web
          middlewares:
            - redirect-to-https

        next-router:
          rule: "Host(`${domain}`) && !PathPrefix(`/api/v1`)"
          service: next-service
          entryPoints:
            - websecure
          tls:
            certResolver: letsencrypt

        api-router:
          rule: "Host(`${domain}`) && PathPrefix(`/api/v1`)"
          service: api-service
          entryPoints:
            - websecure
          tls:
            certResolver: letsencrypt

        ws-router:
          rule: "Host(`${domain}`)"
          service: api-service
          entryPoints:
            - websecure
          tls:
            certResolver: letsencrypt

      services:
        next-service:
          loadBalancer:
            servers:
              - url: "http://pangolin:3002"

        api-service:
          loadBalancer:
            servers:
              - url: "http://pangolin:3000"
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /data/pangolin 0750 root root -"
    "d /data/pangolin/config 0750 root root -"
    "d /data/pangolin/config/traefik 0750 root root -"
    "d /data/pangolin/config/letsencrypt 0750 root root -"
    "d /data/pangolin/volumes 0750 root root -"
    "d /data/pangolin/volumes/pangolin-data 0750 root root -"
  ];

  environment.etc."pangolin/config.yml".source = pangolinConfig;
  environment.etc."pangolin/traefik_config.yml".source = traefikConfig;
  environment.etc."pangolin/dynamic_config.yml".source = traefikDynamicConfig;

  systemd.services.init-pangolin-network = {
    description = "Create pangolin docker network";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "docker-pangolin.service" "docker-gerbil.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect pangolin >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create pangolin --driver bridge
    '';
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  virtualisation.oci-containers.containers = {
    pangolin = {
      image = "fosrl/pangolin:latest";
      autoStart = true;
      networks = [ "pangolin" ];
      volumes = [
        "/etc/pangolin/config.yml:/app/config/config.yml:ro"
        "/data/pangolin/config:/app/config"
        "/data/pangolin/volumes/pangolin-data:/var/certificates"
        "/data/pangolin/volumes/pangolin-data:/var/dynamic"
      ];
      extraOptions = [
        "--name=pangolin"
        "--health-cmd=curl -f http://localhost:3001/api/v1/"
        "--health-interval=3s"
        "--health-timeout=3s"
        "--health-retries=15"
      ];
    };

    gerbil = {
      image = "fosrl/gerbil:latest";
      autoStart = true;
      dependsOn = [ "pangolin" ];
      networks = [ "pangolin" ];
      cmd = [
        "--reachableAt=http://gerbil:3003"
        "--generateAndSaveKeyTo=/var/config/key"
        "--remoteConfig=http://pangolin:3001/api/v1/"
      ];
      volumes = [
        "/data/pangolin/config:/var/config"
      ];
      ports = [
        "51820:51820/udp"
        "21820:21820/udp"
        "443:443"
        "80:80"
      ];
      extraOptions = [
        "--name=gerbil"
        "--cap-add=NET_ADMIN"
        "--cap-add=SYS_MODULE"
      ];
    };

    traefik = {
      image = "traefik:v3.4.0";
      autoStart = true;
      dependsOn = [
        "pangolin"
        "gerbil"
      ];
      cmd = [
        "--configFile=/etc/traefik/traefik_config.yml"
      ];
      volumes = [
        "/etc/pangolin/traefik_config.yml:/etc/traefik/traefik_config.yml:ro"
        "/etc/pangolin/dynamic_config.yml:/etc/traefik/dynamic_config.yml:ro"
        "/data/pangolin/config/letsencrypt:/letsencrypt"
        "/data/pangolin/volumes/pangolin-data:/var/certificates:ro"
        "/data/pangolin/volumes/pangolin-data:/var/dynamic:ro"
      ];
      extraOptions = [
        "--name=traefik"
        "--network=container:gerbil"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    51820
    21820
  ];
}

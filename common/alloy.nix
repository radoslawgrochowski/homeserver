{ config, ... }:
{
  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:28183"
    ];
  };

  environment.etc."alloy/config.alloy".text = ''
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.source.journal "read" {
      max_age       = "12h"
      relabel_rules = loki.relabel.journal.rules
      forward_to    = [loki.write.default.receiver]
      labels        = {
        job  = "systemd-journal",
        host = "${config.networking.hostName}",
      }
    }

    loki.write "default" {
      endpoint {
        url = "http://nimbus:3100/loki/api/v1/push"
      }
    }
  '';
}
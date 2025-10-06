[
  {
    id = "grafana_alerts_webhook";
    alias = "Grafana Alerts Handler";
    trigger = [
      {
        platform = "webhook";
        webhook_id = "grafana_alerts";
      }
    ];
    action = [
      {
        service = "notify.notify";
        data = {
          title = "🚨 {{ trigger.json.title | default('Grafana Alert') }}";
          message = "{{ trigger.json.message | default('Alert triggered') }}";
          data = {
            priority = "{{ trigger.json.priority | default('normal') }}";
            tag = "{{ trigger.json.tag | default('grafana_alert') }}";
          };
        };
      }
    ];
  }
]

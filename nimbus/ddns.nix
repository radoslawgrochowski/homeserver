{ config, pkgs, ... }:
let
  ddnsScript = pkgs.writeShellScript "mydevil-ddns" ''
    set -euo pipefail
    
    # Load configuration from encrypted file
    source ${config.age.secrets.ddns-config.path}
    STATE_DIR="/var/lib/ddns"
    CURRENT_IP_FILE="$STATE_DIR/current_ip"
    LOG_FILE="/var/log/ddns.log"
    
    # Ensure state directory exists
    mkdir -p "$STATE_DIR"
    
    # Function to log messages
    log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
    }
    
    log "Starting DDNS check"
    
    CURRENT_IP=$(${pkgs.curl}/bin/curl -s --max-time 30 https://ipinfo.io/ip || echo "")
    
    if [[ -z "$CURRENT_IP" ]]; then
        log "ERROR: Failed to get current IP"
        exit 1
    fi
    
    log "Current public IP: $CURRENT_IP"
    
    # Check if IP has changed
    if [[ -f "$CURRENT_IP_FILE" ]]; then
        STORED_IP=$(cat "$CURRENT_IP_FILE")
        if [[ "$STORED_IP" == "$CURRENT_IP" ]]; then
            log "IP unchanged: $CURRENT_IP"
            exit 0
        fi
        log "IP changed from $STORED_IP to $CURRENT_IP"
    else
        log "First run, current IP: $CURRENT_IP"
    fi
    
    log "Processing DNS records for: $RECORD_NAME"
    
    # Split comma-separated record names and process each one
    IFS=',' read -ra RECORD_NAMES <<< "$RECORD_NAME"
    UPDATE_SUCCESS=true
    
    for RECORD in "''${RECORD_NAMES[@]}"; do
        # Trim whitespace
        RECORD=$(echo "$RECORD" | xargs)
        log "Processing record: $RECORD"
        
        # Fetch current DNS record ID for this specific record
        RECORD_ID=$(${pkgs.openssh}/bin/ssh -i /etc/ssh/ssh_host_rsa_key \
            -o StrictHostKeyChecking=yes \
            -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts \
            -o LogLevel=ERROR \
            "$MYDEVIL_USER@$MYDEVIL_HOST" \
            "devil dns list $DOMAIN" | grep "^[0-9]\+[[:space:]]\+$RECORD[[:space:]]\+A[[:space:]]\+" | head -1 | awk '{print $1}' || echo "")
        
        if [[ -n "$RECORD_ID" ]]; then
            log "Found existing record ID for $RECORD: $RECORD_ID, updating..."
            ${pkgs.openssh}/bin/ssh -i /etc/ssh/ssh_host_rsa_key \
                -o StrictHostKeyChecking=yes \
                -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts \
                -o LogLevel=ERROR \
                "$MYDEVIL_USER@$MYDEVIL_HOST" \
                "devil dns del $DOMAIN $RECORD_ID"
            log "Deleted old record for $RECORD"
        else
            log "No existing record found for $RECORD, creating new..."
        fi
        
        # Add new DNS record
        ${pkgs.openssh}/bin/ssh -i /etc/ssh/ssh_host_rsa_key \
            -o StrictHostKeyChecking=yes \
            -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts \
            -o LogLevel=ERROR \
            "$MYDEVIL_USER@$MYDEVIL_HOST" \
            "devil dns add $DOMAIN $RECORD A $CURRENT_IP"
        
        if [[ $? -eq 0 ]]; then
            log "Successfully updated DNS record: $RECORD -> $CURRENT_IP"
        else
            log "ERROR: Failed to update DNS record for $RECORD"
            UPDATE_SUCCESS=false
        fi
    done
    
    if [[ "$UPDATE_SUCCESS" == true ]]; then
        echo "$CURRENT_IP" > "$CURRENT_IP_FILE"
    else
        log "ERROR: One or more DNS record updates failed"
        exit 1
    fi
    
    log "DDNS update completed successfully"
  '';
in
{
  # Create dedicated user for DDNS service first
  users.users.ddns = {
    isSystemUser = true;
    group = "ddns";
    description = "DDNS service user";
  };

  users.groups.ddns = { };

  # Create systemd service for DDNS updates
  systemd.services.mydevil-ddns = {
    description = "MyDevil Dynamic DNS Update";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ddnsScript}";
      # TODO:
      # User = "ddns";
      # Group = "ddns";
      StateDirectory = "ddns";
      LogsDirectory = "ddns";
    };
  };

  systemd.timers.mydevil-ddns = {
    description = "MyDevil Dynamic DNS Update Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min"; # Run every 5 minutes
      Persistent = true; # Catch up missed runs
    };
  };



  systemd.tmpfiles.rules = [
    "d /var/log/ddns 0755 ddns ddns -"
    "f /var/log/ddns.log 0644 ddns ddns -"
  ];

  programs.ssh.knownHosts = {
    "s0.mydevil.net" = {
      hostNames = [ "s0.mydevil.net" ];
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCd0U++QBmysEqZI7h+uotdeD84XbiAMxRd2V13c+TRPx4yeLzrzhHNmfn0LrODKSH4Ck2yEgOT5+5gLyHblumzB6O08p7ifgpn62G6mmuYdXcNsUcOtpVq7yUPNQr9j9MGo1gbJudvQZYZlODefTxWb++Su1awm+x3xsZzhXVgkzfZ9surXGS08OabkcyL4Rdy2wQbrIltNJCYPVIbjo4f7O0By9KFmBNYzm/g+nnQbchK+Nhlwnn0ts4Co1qL4QLHtnVJPMVU/yaajkNysK0IRCn3LNgEyrQ/aN/lMhNVa+A6/PpZebs4PlRlHG9um9q8sxn9AYkekm2fClLA05Ct";
    };
    "s0.mydevil.net-ecdsa" = {
      hostNames = [ "s0.mydevil.net" ];
      publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHW9WmxXyRcBi5taLu3/SoPxoW9WJlZe7lcCyDIeXgWaxjcQh6+Z8eUoOgVfnBnHOFBli/gJiKzv/NBM+vRYNJs=";
    };
    "s0.mydevil.net-ed25519" = {
      hostNames = [ "s0.mydevil.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDf4B8BfoJgTNw/wQHvf3meJPq0beYVhUs+pA9cjRv2/";
    };
  };
}


{ ... }:
# see: https://github.com/notohh/snowflake/blob/24c9c4d46344cefc1ae96671061830226d48f35f/hosts/haru/services/blocky.nix#L104
{
  services.blocky = {
    enable = true;
    settings = {
      connectIPVersion = "v4";
      log = {
        level = "debug";
        privacy = true;
      };

      ports = {
        dns = 53;
        http = 4000;
      };

      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
      ];

      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };

      blocking = {
        blackLists = {
          ads = [
            "https://blocklistproject.github.io/Lists/ads.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://adaway.org/hosts.txt"
            "https://v.firebog.net/hosts/AdguardDNS.txt"
            "https://v.firebog.net/hosts/Admiral.txt"
            "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://v.firebog.net/hosts/Easylist.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
            "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
          ];
          tracking = [
            "https://v.firebog.net/hosts/Easyprivacy.txt"
            "https://v.firebog.net/hosts/Prigent-Ads.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
            "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
            "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
          ];
          malicious = [
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
            "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
            "https://v.firebog.net/hosts/Prigent-Crypto.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
            "https://v.firebog.net/hosts/RPiList-Phishing.txt"
            "https://v.firebog.net/hosts/RPiList-Malware.txt"
          ];
          misc = [
            "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
          ];
          catchall = [
            "https://big.oisd.nl/domainswild"
          ];
        };

        clientGroupsBlock = {
          default = [
            "ads"
            "tracking"
            "malicious"
            "misc"
            "catchall"
          ];
        };

      };

      prometheus = {
        enable = true;
        path = "/metrics";
      };
    };

  };

  networking.firewall.allowedTCPPorts = [ 53 4000 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}

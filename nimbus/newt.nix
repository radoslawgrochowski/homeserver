{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.nimbus-newt-env.file = ../secrets/nimbus-newt-env.age;

  # Custom newt service definition using unstable package
  # Not using the nixpkgs module due to lib.cli.toCommandLineShellGNU incompatibility
  systemd.services.newt = {
    description = "Newt, user space tunnel client for Pangolin";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    environment = {
      HOME = "/var/lib/private/newt";
    };

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.unstable.fosrl-newt}";
      DynamicUser = true;
      StateDirectory = "newt";
      StateDirectoryMode = "0700";
      Restart = "always";
      RestartSec = "10s";
      EnvironmentFile = config.age.secrets.nimbus-newt-env.path;
      # hardening
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = "disconnected";
      PrivateDevices = true;
      PrivateUsers = true;
      PrivateMounts = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      LockPersonality = true;
      RestrictRealtime = true;
      ProtectClock = true;
      ProtectProc = "noaccess";
      ProtectHostname = true;
      RemoveIPC = true;
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_UNIX"
      ];
      CapabilityBoundingSet = [
        "~CAP_BLOCK_SUSPEND"
        "~CAP_BPF"
        "~CAP_CHOWN"
        "~CAP_MKNOD"
        "~CAP_NET_RAW"
        "~CAP_PERFMON"
        "~CAP_SYS_BOOT"
        "~CAP_SYS_CHROOT"
        "~CAP_SYS_MODULE"
        "~CAP_SYS_NICE"
        "~CAP_SYS_PACCT"
        "~CAP_SYS_PTRACE"
        "~CAP_SYS_TIME"
        "~CAP_SYS_TTY_CONFIG"
        "~CAP_SYSLOG"
        "~CAP_WAKE_ALARM"
      ];
      SystemCallFilter = [
        "~@aio:EPERM"
        "~@chown:EPERM"
        "~@clock:EPERM"
        "~@cpu-emulation:EPERM"
        "~@debug:EPERM"
        "~@keyring:EPERM"
        "~@memlock:EPERM"
        "~@module:EPERM"
        "~@mount:EPERM"
        "~@obsolete:EPERM"
        "~@pkey:EPERM"
        "~@privileged:EPERM"
        "~@raw-io:EPERM"
        "~@reboot:EPERM"
        "~@resources:EPERM"
        "~@sandbox:EPERM"
        "~@setuid:EPERM"
        "~@swap:EPERM"
        "~@sync:EPERM"
        "~@timer:EPERM"
      ];
    };
  };
}

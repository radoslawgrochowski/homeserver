{ ... }:

let
  backupDir = "/tank/postgresql-backup";
in
{
  systemd.tmpfiles.rules = [
    "d ${backupDir} 0750 postgres postgres -"
  ];

  services.postgresqlBackup = {
    enable = true;
    location = backupDir;
    startAt = "*-*-* 01:33:00";
  };
}

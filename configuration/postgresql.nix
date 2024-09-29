{ ... }: {
  services.postgresqlBackup = {
    enable = true;
    location = "/var/backup/postgresql";
    startAt = "*-*-* 04:30:00";
  };
}

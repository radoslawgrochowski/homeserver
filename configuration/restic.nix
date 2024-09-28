{ config, ... }:
{
  services.restic.backups = {
    media = {
      initialize = true;
      paths = [
        "/share/media/gallery"
        "/share/media/photos"
      ];
      repositoryFile = config.age.secrets.restic-repository.path;
      environmentFile = config.age.secrets.restic-env.path;
      passwordFile = config.age.secrets.restic-password.path;
      timerConfig = {
        OnCalendar = "05:00";
        RandomizedDelaySec = "2h";
        Persistent = true;
      };
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 3"
        "--keep-monthly 3"
        "--keep-yearly 3"
      ];
    };
  };
}

{ ... }: {
  age.secrets.restic-password.file = ../secrets/restic-password.age;
  age.secrets.restic-env.file = ../secrets/restic-env.age;
  age.secrets.restic-repository.file = ../secrets/restic-repository.age;
}

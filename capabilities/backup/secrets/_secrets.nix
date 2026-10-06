let
  # Underscore keeps this agenix rules file out of import-tree's module scan.
  # SSH host keys already pinned in the administrator's known_hosts.
  oslo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGla4OOitU1rW6Ryj50Th3lhZfRN1NuF5KhF9M9Fftn";
  svalbard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXT1W/d2w2KkyiqVrueiW+RCDEA8VDr4IHGHdW6cZQ5";
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbj7iF2skCHXK7Mil4xtdrGjFr69S1wA2YtFvjLgxEG";
  paris = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+VOouatDdN2oqpwfDtzJqDvrx9YJwbvs3of1aZ8Q24";
  recipients = [
    oslo
    svalbard
    personal
    paris
  ];
in
{
  "washington-ssh-key.age" = {
    publicKeys = recipients;
    armor = true;
  };
  "washington-restic-password.age" = {
    publicKeys = recipients;
    armor = true;
  };
}

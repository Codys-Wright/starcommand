# Base host defaults shared by all hosts in this flake
{
  FTS,
  __findFile,
  ...
}:
{
  FTS.base-host = {
    description = "Base host defaults shared by all starcommand hosts";

    nixos = {
      # NixOS state version — bump only when migrating
      system.stateVersion = "24.11";

      # Nix garbage collection
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      programs.nh.enable = true;
    };
  };
}

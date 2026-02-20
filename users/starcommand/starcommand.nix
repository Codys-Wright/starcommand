{
  den,
  FTS,
  __findFile,
  ...
}: {
  den = {
    homes.x86_64-linux.starcommand = {
      userName = "starcommand";
      aspect = "starcommand";
    };

    aspects.starcommand = {
      description = "Self-hosting services user (starcommand)";

      includes = [
        <den/primary-user> # Admin privileges and user configuration
        (<den/user-shell> "fish") # Set fish as default shell

        # All self-hosting services
        (FTS.selfhost { })
      ];
    };
  };
}

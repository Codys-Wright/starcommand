# Bootstrap flake.nix — regenerate with: nix run .#write-flake
{
  inputs = {
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";
    selfhostblocks.url = "github:Codys-Wright/selfhostblocks";
    systems.url = "github:nix-systems/default";

    # Pin nixpkgs to selfhostblocks' version — ensures patches apply cleanly
    nixpkgs.follows = "selfhostblocks/nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-file.flakeModules.default
        (inputs.import-tree ./modules)
        (inputs.import-tree ./hosts)
        (inputs.import-tree ./users)
      ];
    };
}

{
  description = "Starcommand - Self-hosting infrastructure";

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)
        (inputs.import-tree ./hosts)
        (inputs.import-tree ./users)
      ];
    };

  inputs = {
    den.url = "github:vic/den";
    deploy-rs.url = "github:serokell/deploy-rs";
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    flake-aspects.url = "github:vic/flake-aspects";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    import-tree.url = "github:vic/import-tree";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixpkgs-lib.follows = "nixpkgs";

    # Pin nixpkgs to selfhostblocks' compatible version — ensures patches apply cleanly
    nixpkgs.follows = "selfhostblocks/nixpkgs";

    selfhostblocks.url = "github:Codys-Wright/selfhostblocks";
    sops-nix.url = "github:Mic92/sops-nix";
    systems.url = "github:nix-systems/default";
  };
}

{ inputs, lib, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic)
  ];

  # Core framework inputs
  flake-file.inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
  flake-file.inputs.flake-aspects.url = lib.mkDefault "github:vic/flake-aspects";
  flake-file.inputs.den.url = lib.mkDefault "github:vic/den";
  flake-file.inputs.import-tree.url = lib.mkDefault "github:vic/import-tree";
  flake-file.inputs.systems.url = lib.mkDefault "github:nix-systems/default";

  # nixpkgs follows selfhostblocks — guarantees patches always apply
  # url must be cleared (empty string = skipped by inputsExpr) so follows is the only entry
  flake-file.inputs.nixpkgs.url = lib.mkForce "";
  flake-file.inputs.nixpkgs.follows = "selfhostblocks/nixpkgs";
  flake-file.inputs.nixpkgs-lib.follows = "nixpkgs";

  # Self-hosting
  flake-file.inputs.selfhostblocks.url = lib.mkDefault "github:Codys-Wright/selfhostblocks";
  flake-file.inputs.sops-nix.url = lib.mkDefault "github:Mic92/sops-nix";

  # System
  flake-file.inputs.disko.url = lib.mkDefault "github:nix-community/disko";
  flake-file.inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  flake-file.inputs.nixos-facter-modules.url = lib.mkDefault "github:numtide/nixos-facter-modules";

  flake-file = {
    description = "Starcommand - Self-hosting infrastructure";
    outputs = lib.mkForce ''
      inputs:
        inputs.flake-parts.lib.mkFlake { inherit inputs; } {
          imports = [
            (inputs.import-tree ./modules)
            (inputs.import-tree ./hosts)
            (inputs.import-tree ./users)
          ];
        }
    '';
  };
}

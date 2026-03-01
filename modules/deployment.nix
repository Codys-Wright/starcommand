# Declares deployment options read by modules/flake/deploy-rs.nix
# Hosts include this aspect and set deployment.ip, deployment.sshPort, etc.
{ lib, den, ... }:
{
  # Base deployment aspect that defines options
  den.aspects.deployment-base = {
    description = "Base deployment options for deploy-rs";
    nixos = { lib, ... }: {
      options.deployment = {
        enable = lib.mkEnableOption "deploy-rs deployment" // { default = true; };

        ip = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "IP address for deploy-rs to target";
        };

        sshPort = lib.mkOption {
          type = lib.types.port;
          default = 22;
          description = "SSH port for deploy-rs";
        };

        sshUser = lib.mkOption {
          type = lib.types.str;
          default = "root";
          description = "SSH user for deploy-rs";
        };
      };
    };
  };
}

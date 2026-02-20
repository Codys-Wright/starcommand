# Declares deployment options read by modules/flake/deploy-rs.nix
# Hosts set deployment.ip, deployment.sshPort, etc. in their nixos config
{ lib, ... }:
{
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
}

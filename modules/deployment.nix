# Declares deployment.* NixOS options via FTS aspect
# Included by hosts that use deploy-rs for remote deployment
{ FTS, ... }: {
  FTS.deployment-options = {
    description = "NixOS options for deploy-rs deployment configuration";
    nixos =
      { lib, ... }:
      {
        options.deployment = {
          enable = lib.mkEnableOption "deploy-rs deployment" // {
            default = true;
          };

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

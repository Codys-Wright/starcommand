# Samba Server
# Advertises SMB shares for network file access
{
  FTS,
  inputs,
  lib,
  ...
}:
{
  FTS.selfhost._.samba-server =
    {
      enable ? true,
      shares ? {},
      ...
    }@args:
    {
      class,
      aspect-chain,
    }:
    {
      description = ''
        Samba Server - SMB file sharing for network access.

        Provides:
        - SMB shares advertised via NetBIOS/mDNS
        - Guest and authenticated access options
        - Works with Windows, macOS, and Linux clients
      '';

      nixos = {
        config,
        lib,
        pkgs,
        ...
      }: {
        services.samba = {
          enable = true;
          openFirewall = true;
          settings = {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "starcommand";
              "netbios name" = "starcommand";
              "security" = "user";
              "map to guest" = "Bad User";
              "guest account" = "nobody";
              # Performance tuning for 10G
              "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
              # mDNS/Avahi advertisement
              "multicast dns register" = "yes";
            };
            # Main storage share - read/write guest access
            storage = {
              path = "/mnt/storage";
              browseable = "yes";
              "read only" = "no";
              "guest ok" = "yes";
              "create mask" = "0664";
              "directory mask" = "0775";
              "force user" = "root";
              "force group" = "root";
            };
            # Media share - read-only guest access
            media = {
              path = "/mnt/storage/media";
              browseable = "yes";
              "read only" = "yes";
              "guest ok" = "yes";
            };
          };
        };

        # Enable Avahi for mDNS/Bonjour advertisement
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          publish = {
            enable = true;
            addresses = true;
            workstation = true;
          };
          extraServiceFiles = {
            smb = ''
              <?xml version="1.0" standalone='no'?>
              <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
              <service-group>
                <name replace-wildcards="yes">%h</name>
                <service>
                  <type>_smb._tcp</type>
                  <port>445</port>
                </service>
              </service-group>
            '';
          };
        };

        # wsdd for Windows network discovery (WS-Discovery)
        services.samba-wsdd = {
          enable = true;
          openFirewall = true;
        };

        # NetBIOS name resolution
        services.samba.nmbd.enable = true;
      };
    };
}

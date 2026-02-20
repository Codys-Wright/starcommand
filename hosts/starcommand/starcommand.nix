{
  inputs,
  den,
  __findFile,
  ...
}: {
  den.hosts.x86_64-linux = {
    starcommand = {
      description = "Dedicated selfhosting server";
      users.starcommand = {}; # Service user for self-hosting infrastructure
      aspect = "starcommand-host";

      # Use selfhostblocks' own nixpkgs (pinned via flake.nix follows) with its patches applied
      # Since inputs.nixpkgs follows selfhostblocks/nixpkgs, patches always apply cleanly
      instantiate = args: let
        system = "x86_64-linux";
        pkgs' = inputs.nixpkgs.legacyPackages.${system};
        shbPatches = inputs.selfhostblocks.lib.${system}.patches;
        patchedNixpkgs = pkgs'.applyPatches {
          name = "nixpkgs-shb-patched";
          src = inputs.nixpkgs;
          patches = shbPatches;
        };
        nixosSystem' = import "${patchedNixpkgs}/nixos/lib/eval-config.nix";
      in
        nixosSystem' (args // {inherit system;});
    };
  };

  den.aspects = {
    starcommand-host = {
      nixos = {
        config,
        lib,
        pkgs,
        ...
      }: {
        imports = [
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.disko.nixosModules.disko
        ];

        # Deployment options — read by modules/flake/deploy-rs.nix
        options.deployment = {
          enable = lib.mkEnableOption "deploy-rs deployment" // {default = true;};
          ip = lib.mkOption {type = lib.types.str; default = ""; description = "IP for deploy-rs";};
          sshPort = lib.mkOption {type = lib.types.port; default = 22;};
          sshUser = lib.mkOption {type = lib.types.str; default = "root";};
        };

        # Hardware detection via nixos-facter
        facter.reportPath = ./facter.json;

        # Disko disk configuration — btrfs with impermanence
        disko.devices.disk.main = {
          device = "/dev/nvme0n1";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              esp = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {mountpoint = "/";};
                    "/persist" = {mountpoint = "/persist";};
                    "/nix" = {
                      mountOptions = ["noatime"];
                      mountpoint = "/nix";
                    };
                  };
                };
              };
            };
          };
        };

        # Deployment config — read by modules/flake/deploy-rs.nix
        deployment = {
          enable = true;
          ip = "192.168.0.102";
          sshPort = 22;
          sshUser = "root";
        };

        # Bootstrap: root password and SSH keys for initial access
        users.users.root = {
          initialPassword = "password";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8y8AMfYQnvu3BvjJ54/qYJcedNkMHmnjexine1ypda cody"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBJxxU1TXbV1IvGFm67X7jX+C7uRtLcgimcoDGxapNP starcommand-deploy"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDSw8Dx6n7gfGztnPQxq4Pp58k/n5JGZE/omfrB3yDp starcommand-deploy-mac"
          ];
        };

        # GRUB bootloader (UEFI)
        boot.loader.grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          efiInstallAsRemovable = true;
          configurationLimit = 25;
        };
        boot.loader.efi.canTouchEfiVariables = false;

        # MergerFS, NTFS, and SMB packages
        environment.systemPackages = with pkgs; [
          mergerfs
          ntfs3g
          cifs-utils
        ];

        # Data drives (NTFS via ntfs-3g)
        fileSystems."/mnt/disks/archive" = {
          device = "/dev/disk/by-uuid/36C0F5ACC0F5730B";
          fsType = "ntfs-3g";
          options = ["rw" "uid=0" "gid=0" "dmask=000" "fmask=000" "nofail"];
        };
        fileSystems."/mnt/disks/collection" = {
          device = "/dev/disk/by-uuid/02A01CC8A01CC3D7";
          fsType = "ntfs-3g";
          options = ["rw" "uid=0" "gid=0" "dmask=000" "fmask=000" "nofail"];
        };

        # MergerFS mount combining all disks
        fileSystems."/mnt/storage" = {
          device = "/mnt/disks/archive:/mnt/disks/collection";
          fsType = "fuse.mergerfs";
          options = [
            "cache.files=partial"
            "dropcacheonclose=true"
            "category.create=mfs"
            "allow_other"
            "nofail"
          ];
        };

        # SMB mount to Synology NAS "TheVault"
        fileSystems."/mnt/synology-vault" = {
          device = "//192.168.0.114/Media";
          fsType = "cifs";
          options = [
            "username=soundaddiction"
            "password=C#major7"
            "vers=1.0"
            "uid=0"
            "gid=0"
            "dir_mode=0755"
            "file_mode=0644"
            "nofail"
            "x-systemd.automount"
            "x-systemd.mount-timeout=10"
          ];
        };

        # Service data directories on merged storage
        systemd.tmpfiles.rules = [
          "d /mnt/storage/torrents 0777 root root -"
          "d /mnt/storage/youtube 0777 root root -"
          "d /mnt/storage/photos 0777 root root -"
          "d /mnt/storage/nextcloud-data 0777 root root -"
          "d /mnt/storage/media 0777 root root -"
          "d /mnt/storage/media/movies 0777 root root -"
          "d /mnt/storage/media/tv 0777 root root -"
          "d /mnt/storage/media/music 0777 root root -"
          "d /mnt/storage/media/audiobooks 0777 root root -"
          "d /etc/smb-credentials 0750 root root -"
        ];

        # 10G direct link — static IP + DHCP server for local switch
        networking.interfaces.enp33s0.ipv4.addresses = [
          {
            address = "10.10.10.1";
            prefixLength = 24;
          }
        ];

        services.dnsmasq = {
          enable = true;
          settings = {
            interface = "enp33s0";
            bind-interfaces = true;
            dhcp-range = "10.10.10.100,10.10.10.200,24h";
            port = 0; # DHCP only, no DNS
          };
        };

        networking.firewall.interfaces.enp33s0.allowedUDPPorts = [67];

        # Automatic cleanup
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        programs.nh.enable = true;

        # Disable all sleep/suspend/hibernate
        systemd.sleep.extraConfig = ''
          AllowSuspend=no
          AllowHibernation=no
          AllowSuspendThenHibernate=no
          AllowHybridSleep=no
        '';

        services.logind = {
          powerKey = "ignore";
          powerKeyLongPress = "poweroff";
          lidSwitch = "ignore";
          lidSwitchDocked = "ignore";
          lidSwitchExternalPower = "ignore";
        };
      };
    };
  };
}

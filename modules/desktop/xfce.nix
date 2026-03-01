# XFCE Desktop Environment
# Lightweight desktop for servers that need occasional GUI access
{
  FTS,
  lib,
  ...
}: {
  FTS.desktop._.xfce = {
    description = ''
      Lightweight XFCE desktop environment.

      Suitable for servers that need occasional GUI access
      without the overhead of a full desktop environment.
    '';

    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      # Enable X11 and XFCE
      services.xserver = {
        enable = true;
        desktopManager.xfce.enable = true;
      };

      # LightDM display manager
      services.displayManager = {
        defaultSession = "xfce";
      };
      services.xserver.displayManager.lightdm = {
        enable = true;
        greeters.slick.enable = true;
      };

      # Basic X11 settings
      services.libinput.enable = true;

      # Useful XFCE packages
      environment.systemPackages = with pkgs; [
        # File manager
        xfce.thunar
        xfce.thunar-volman
        xfce.thunar-archive-plugin

        # Terminal
        xfce.xfce4-terminal

        # Utilities
        xfce.xfce4-taskmanager
        xfce.xfce4-screenshooter
        xfce.xfce4-notifyd

        # Basic apps
        firefox
        xfce.mousepad  # Text editor

        # Archive support
        xarchiver
        p7zip
        unzip
      ];

      # Enable sound
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      # Enable printing (optional)
      services.printing.enable = lib.mkDefault false;

      # Fonts
      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        liberation_ttf
        dejavu_fonts
      ];
    };
  };
}

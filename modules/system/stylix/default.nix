{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.stylix;
in {
  options.modules.stylix = {
    enable = lib.mkEnableOption "enable stylix";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;

      polarity = "dark";

      image = pkgs.fetchurl {
        url = "https://wallpaperswide.com/download/toyota_supra_neon_sports_car-wallpaper-3840x2160.jpg";
        hash = "sha256-cpOCfxZRw5GocoPSjixqG+hbv3olVhz6f+2QF2N/wm8=";
      };

      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

      opacity = {
        applications = 1.0;
        terminal = 0.75;
        desktop = 0.75;
        popups = 0.5;
      };

      fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };

        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };

        monospace = {
          package = pkgs.nerd-fonts.monaspace;
          name = "MonaspiceNe Nerd Font Mono";
        };

        emoji = {
          package = pkgs.joypixels;
          name = "JoyPixels";
        };
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      targets = {
        plymouth.enable = false;
      };
    };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "joypixels"
      ];
    nixpkgs.config.joypixels.acceptLicense = true;
  };
}

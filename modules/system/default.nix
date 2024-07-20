{
  inputs,
  user,
  language,
  timeZone,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./greetd
    ./i18n
    ./keyboard
    ./networking
    ./nh
    ./polkit
    ./shell
    ./sound
    ./stylix
  ];

  modules = {
    greetd.enable = lib.mkDefault true;

    i18n = {
      enable = lib.mkDefault true;
      language = language;
    };

    networking = {
      enable = lib.mkDefault true;
      wireless.enable = lib.mkDefault true;
    };

    nh.enable = lib.mkDefault true;

    sound.enable = lib.mkDefault true;

    polkit.enable = lib.mkDefault true;

    shell = {
      enable = lib.mkDefault true;
      fish.enable = lib.mkDefault true;
    };

    stylix.enable = lib.mkDefault true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = lib.mkAfter [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    plymouth = {
      enable = true;
      themePackages = with pkgs; [
        adi1090x-plymouth-themes
      ];
      theme = "lone";
    };
  };

  users.users.${user} = {
    isNormalUser = true;
    description = "${user}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  time.timeZone = timeZone;

  services = {
    printing.enable = true;
    xserver.enable = true;
  };

  system.stateVersion = "23.11";
}

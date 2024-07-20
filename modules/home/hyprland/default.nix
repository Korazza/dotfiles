{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {
    enable = lib.mkEnableOption "enable hyprland wm";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.programs.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;

      settings = {
        "$mod" = "ALT";
        "$terminal" = "kitty";
        "$fileManager" = "nautilus";
        "$browser" = "brave";

        general = {
          border_size = 0;
          allow_tearing = false;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        decoration = {
          rounding = 12;

          #active_opacity = 0.75;
          #inactive_opacity = 0.75;

          blur = {
            enabled = true;
            size = 20;
            passes = 3;
            ignore_opacity = false;
            noise = 0.01;
            contrast = 0.9;
            brightness = 0.6;
            vibrancy = 0.75;
            vibrancy_darkness = 0.75;
            popups = true;
          };
        };

        animations = {
          enabled = true;
          bezier = "ease-out-circ, 0, 0.55, 0.45, 1";
          animation = [
            "windows, 1, 3, ease-out-circ, popin"
            "border, 1, 3, ease-out-circ"
            "borderangle, 1, 3, ease-out-circ"
            "fade, 1, 3, ease-out-circ"
            "workspaces, 1, 3, ease-out-circ, slide"
          ];
        };

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        bind =
          [
            "$mod, ESCAPE, killactive,"
            "$mod, F, togglefloating,"
            "$mod, SPACE, fullscreen"
            "$mod, K, togglegroup,"
            "$mod, Tab, changegroupactive, f"
            "$mod, up, movefocus, u"
            "$mod, right, movefocus, r"
            "$mod, down, movefocus, d"
            "$mod, left, movefocus, l"
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"
            # media
            ",XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +2%"
            ",XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -2%"
            ",XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle"
            ",XF86AudioMicMute,exec,pactl set-source-mute @DEFAULT_SINK@ toggle"
            ",XF86AudioPlay,exec,playerctl play-pause"
            ",XF86AudioPause,exec,playerctl play-pause"
            ",XF86AudioPrev,exec,playerctl previous"
            ",XF86AudioNext,exec,playerctl next"
            ",PAUSE,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle"
            # apps
            "$mod, RETURN, exec, $terminal"
            "$mod, E, exec, $fileManager"
            "$mod, B, exec, $browser"
            "$mod, D, exec, ags -t applauncher"
            "$mod, Q, exec, ags -t quicksettings"
            "$mod, BACKSPACE, exec, ags -t powermenu"
            "$mod, C, exec, vesktop"
            "$mod, V, exec, code"
            "$mod, S, exec, spotify"
            "$mod, O, exec, obsidian"
          ]
          ++ (
            builtins.concatLists (
              builtins.genList (
                x: let
                  ws = let
                    c = (x + 1) / 10;
                  in
                    builtins.toString (x + 1 - (c * 10));
                in [
                  "$mod, ${ws}, workspace, ${toString (x + 1)}"
                  "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                ]
              )
              10
            )
          );

          windowrulev2 = [
            "suppressevent maximize, class:.*"
          ];
      };
    };
  };
}

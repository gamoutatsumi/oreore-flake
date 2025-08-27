{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.theme.wallpaper;
  wallpaperType = lib.types.submodule {
    options = {
      file = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      xdg = {
        display = lib.mkOption {
          type = lib.types.enum [
            "center"
            "fill"
            "max"
            "scale"
            "tile"
          ];
          default = "fill";
        };
      };
    };
  };
in
{
  options = {
    theme = {
      wallpaper = lib.mkOption {
        type = wallpaperType;
        default = { };
      };
    };
  };
  config =
    let
      initScript =
        let
          flags = lib.concatStringsSep " " [
            "--bg-${cfg.xdg.display}"
            "--no-fehbg"
          ];
        in
        ''
          ${lib.getExe pkgs.feh} ${flags} ${cfg.file} &
        '';
    in
    lib.mkIf (cfg.file != null) {
      systemd = {
        user = {
          services = {
            feh = {
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
              Unit = {
                Description = "Setting Wallpaper";
                After = [ "basic.target" ];
                PartOf = [ "graphical-session.target" ];
              };
              Service = {
                Type = "oneshot";
                ExecStart = initScript;
              };
            };
          };
        };
      };
    };
}

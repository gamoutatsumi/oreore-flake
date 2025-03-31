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
  config = lib.mkIf (cfg.file != null) {
    xsession = lib.mkIf config.xsession.enable {
      initExtra =
        let
          flags = lib.concatStringsSep " " [
            "--bg-${cfg.xdg.display}"
            "--no-fehbg"
          ];
        in
        ''
          ${lib.getExe pkgs.feh} ${flags} ${cfg.file} &
        '';
    };
  };
}

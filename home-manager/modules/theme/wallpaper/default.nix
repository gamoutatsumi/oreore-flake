{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.theme.wallpaper;
  flags = lib.concatStringsSep " " (
    [
      "--bg-${cfg.display}"
      "--no-fehbg"
    ]
    ++ lib.optional (!cfg.enableXinerama) "--no-xinerama"
  );
in
{
  options = {
    xsession = {
      wallpaper = {
        file = lib.mkOption {
          type = lib.types.path;
        };
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
  config = lib.mkIf (cfg.wallpaper ? file) {
    xsession = lib.mkIf config.xsession.enable {
      initExtra = ''
        ${pkgs.feh}/bin/feh ${flags} ${cfg.file} &
      '';
    };
  };
}

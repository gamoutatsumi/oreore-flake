{
  config,
  lib,
  pkgs,
  ...
}:
(
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
)
// (
  let
    cfg = config.theme.tinty;
    settingsFormat = pkgs.formats.toml { };
    cfgFile = settingsFormat.generate "config.toml" cfg.settings;
  in
  {
    options = {
      theme = {
        tinty = {
          enable = lib.mkEnableOption "Enable tinty for Tinted-Theming (base16 / base24)";
          settings = lib.mkOption {
            type = settingsFormat.type;
          };
          package = lib.mkPackageOption pkgs "tinty" { };
        };
      };
    };
    config = lib.mkIf cfg.enable {
      xdg = {
        configFile = {
          "tinted-theming/tinty/config.toml" = {
            source = cfgFile;
          };
        };
        dataFile = lib.mkIf (config.theme.wallpaper ? file) {
          "tinted-theming/tinty/custom-schemes/wallpaper.toml" = {
            source =
              pkgs.runCommand "wallpaper.toml"
                {
                  nativeBuildInputs = [ cfg.package ];
                }
                ''
                  export XDG_DATA_HOME=$(mktemp -d)
                              tinty --config-file ${cfgFile} --system base24 --save $out ${config.theme.wallpaper.file}
                '';
          };
        };
      };
    };
  }
)

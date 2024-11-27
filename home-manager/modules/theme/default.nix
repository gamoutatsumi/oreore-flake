{
  config,
  lib,
  pkgs,
  ...
}:
(
  let
    cfg = config.theme.wallpaper;
    wallpaper = lib.types.submodule {
      options = {
        file = lib.mkOption {
          type = lib.types.path;
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
          type = wallpaper;
        };
      };
    };
    config = lib.mkIf (cfg.file != null) {
      xsession = lib.mkIf config.xsession.enable {
        initExtra =
          let
            flags = lib.concatStringsSep " " ([
              "--bg-${cfg.xdg.display}"
              "--no-fehbg"
              "--no-xinerama"
            ]);
          in
          ''
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
    tinty = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Enable tinty for Tinted-Theming (base16 / base24)";
        settings = lib.mkOption {
          type = settingsFormat.type;
        };
        package = lib.mkPackageOption pkgs "tinty" { };
      };
    };
  in
  {
    options = {
      theme = {
        tinty = lib.mkOption {
          type = tinty;
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

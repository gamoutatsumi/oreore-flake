{
  config,
  lib,
  pkgs,
  ...
}:
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

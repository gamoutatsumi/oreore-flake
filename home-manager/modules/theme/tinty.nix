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
  tintyType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "Enable tinty for Tinted-Theming (base16 / base24)";
      settings = lib.mkOption {
        type = settingsFormat.type;
        default = { };
      };
      package = lib.mkPackageOption pkgs "tinty" { };
      variant = lib.mkOption {
        type = lib.types.enum [
          "light"
          "dark"
        ] "The variant of the theme to use";
        default = "light";
      };
    };
  };
in
{
  options = {
    theme = {
      tinty = lib.mkOption {
        type = tintyType;
        default = { };
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
      dataFile = lib.mkIf (config.theme.wallpaper.file != null) {
        "tinted-theming/tinty/custom-schemes/wallpaper.toml" = {
          source =
            pkgs.runCommand "wallpaper.toml"
              {
                nativeBuildInputs = [ cfg.package ];
              }
              ''
                export XDG_DATA_HOME=$(mktemp -d)
                            tinty generate-scheme --config ${cfgFile} --system base24 --name Wallpaper --slug wallpaper --variant ${cfg.variant} ${config.theme.wallpaper.file} > $out
              '';
        };
      };
    };
  };
}

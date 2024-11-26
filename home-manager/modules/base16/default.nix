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
        generate = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                system = lib.mkOption {
                  type = lib.types.enum [
                    "base16"
                    "base24"
                  ];
                };
                image = lib.mkOption {
                  type = lib.path;
                };
              };
            }
          );
        };
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
      dataFile = lib.attrsets.mapAttrs (name: value: {
        "tinted-theming/tinty/custom-schemes/${name}.toml" = {
          source =
            pkgs.runCommand "${name}.toml"
              {
                nativeBuildInputs = [ cfg.package ];
              }
              ''
                export XDG_DATA_HOME=$(mktemp -d)
                            tinty --config-file ${cfgFile} --system ${value.system} --save $out ${value.image}
              '';
        };
      }) cfg.generate;
    };
  };
}

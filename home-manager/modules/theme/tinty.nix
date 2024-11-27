{ localFlake }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  selfPkgs' = localFlake.packages."${system}";
  cfg = config.theme.tinty;
  settingsFormat = pkgs.formats.toml { };
  genCfgFile = settings: settingsFormat.generate "config.toml" (settings // cfg.settings);
  cfgFile = genCfgFile {
    shell = "${cfg.shell} -c '{}'";
    default-scheme = cfg.scheme;
  };
  itemType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
      };
      path = lib.mkOption {
        type = lib.types.path;
      };
      themes-dir = lib.mkOption {
        type = lib.types.path;
      };
      hooks = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      supported-systems = lib.mkOption {
        type = lib.types.list (
          lib.types.enum [
            "base16"
            "base24"
          ]
        );
      };
    };
  };
  tintyType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "Enable tinty for Tinted-Theming (base16 / base24)";
      settings = lib.mkOption {
        type = settingsFormat.type;
        default = { };
      };
      package = lib.mkPackageOption selfPkgs' "tinty" { };
      shell = lib.mkOption {
        type = lib.types.str;
        default = "bash";
      };
      scheme = lib.mkOption {
        type = lib.types.str;
        default = if config.theme.wallpaper.file != null then "base24-wallpaper" else "base16-mocha";
      };
      generate = {
        variant = lib.mkOption {
          type = lib.types.enum [
            "light"
            "dark"
          ];
          default = "light";
        };
      };
      items = lib.mkOption {
        type = lib.types.list itemType;
        default = [ ];
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
    home = {
      packages = [ cfg.package ];
    };
    xdg = {
      dataFile = lib.mkIf (config.theme.wallpaper.file != null) {
        "tinted-theming/tinty/" = {
          source =
            pkgs.runCommand "tinty"
              {
                nativeBuildInputs = [ cfg.package ];
              }
              ''
                tinty generate-scheme --config ${cfgFile} --data-dir $out --system base24 --name 'Base24 Wallpaper' --slug base24-wallpaper --variant ${cfg.generate.variant} --save ${config.theme.wallpaper.file}
                tinty install --config ${cfgFile} --data-dir $out
                tinty apply --config ${cfgFile} --data-dir $out ${cfg.scheme}
              '';
        };
      };
    };
  };
}

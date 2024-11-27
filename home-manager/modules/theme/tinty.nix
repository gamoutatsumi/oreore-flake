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
    items = cfg.items;
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
        type = lib.types.str;
      };
      hooks = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      supported-systems = lib.mkOption {
        type = lib.types.listOf (
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
        type = lib.types.listOf itemType;
        default = [ ];
      };
      schemesSrc = lib.mkOption {
        type = lib.types.package;
        default = pkgs.fetchFromGitHub {
          owner = "tinted-theming";
          repo = "schemes";
          rev = "61058a8d2e2bd4482b53d57a68feb56cdb991f0b"; # spec-0.11
          hash = "sha256-Tp1BpaF5qRav7O2TsSGjCfgRzhiasu4IuwROR66gz1o=";
        };
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
                mkdir -p $out/repos
                cp -r ${cfg.schemesSrc} $out/repos/schemes
                tinty generate-scheme --config ${cfgFile} --data-dir $out --system base24 --name 'Base24 Wallpaper' --slug base24-wallpaper --variant ${cfg.generate.variant} --save ${config.theme.wallpaper.file}
                tinty install --config ${cfgFile} --data-dir $out
                #tinty apply --config ${cfgFile} --data-dir $out ${cfg.scheme}
              '';
        };
      };
    };
  };
}

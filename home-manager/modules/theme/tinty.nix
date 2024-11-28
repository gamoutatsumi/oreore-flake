{ localFlake, tintySchemes }:
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
  items = builtins.map (v: {
    name = v.name;
    path = v.url;
    themes-dir = v.themes-dir;
    hooks = v.hooks;
    supported-systems = v.supported-systems;
  }) cfg.items;
  cfgFile = genCfgFile {
    shell = "${cfg.shell} -c '{}'";
    default-scheme = cfg.scheme;
    items = items;
  };
  itemType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
      };
      path = lib.mkOption {
        type = lib.types.path;
      };
      url = lib.mkOption {
        type = lib.types.str;
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
  repos = pkgs.symlinkJoin {
    name = "repos";
    paths = builtins.map (
      v:
      pkgs.stdenvNoCC.mkDerivation {
        pname = v.name;
        version = "0.0.0";
        src = v.path;
        installPhase = ''
          mkdir -p $out/${v.name}
          cp -r $src/* $out/${v.name}
        '';
      }
    ) cfg.items;
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
      activation = {
        tintyApply = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          (
          export XDG_CONFIG_HOME=${lib.escapeShellArg config.xdg.configHome}
          export XDG_DATA_HOME=${lib.escapeShellArg config.xdg.dataHome}
          verboseEcho "Applying tinty theme"
          cd "${pkgs.emptyDirectory}"
          run ${lib.getExe cfg.package} apply ${cfg.scheme}
          )
        '';
      };
    };
    xdg = {
      configFile = {
        "tinted-theming/tinty/config.toml" = {
          source = cfgFile;
        };
      };
      dataFile = {
        "tinted-theming/tinty/" = {
          source =
            pkgs.runCommand "tinty"
              {
                nativeBuildInputs = [ cfg.package ];
              }
              (
                ''
                  mkdir -p $out/repos
                  cp -r ${repos}/* $out/repos
                  find $out/repos -type d -exec chmod 755 {} \;
                  cp -r ${tintySchemes} $out/repos/schemes
                  ${
                    if (config.theme.wallpaper.file != null) then
                      ''
                        tinty generate-scheme --config ${cfgFile} --data-dir $out --system base24 --name 'Wallpaper' --slug 'wallpaper' --variant ${cfg.generate.variant} --save ${config.theme.wallpaper.file}
                      ''
                    else
                      ""
                  }
                  tinty install --config ${cfgFile} --data-dir $out
                ''
                + lib.strings.concatLines (
                  builtins.map (v: ''tinty build --config ${cfgFile} --data-dir $out $out/repos/${v.name}'') cfg.items
                )
              );
        };
      };
    };
  };
}

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
  items =
    (lib.optionals cfg.themes.alacritty.enable [
      {
        name = "tinted-alacritty";
        path = cfg.themes.alacritty.repo;
        url = "https://github.com/tinted-theming/tinted-alacritty";
        themes-dir = "colors-256";
        supported-systems = [
          "base16"
          "base24"
        ];
      }
    ])
    ++ (lib.optionals cfg.themes.shell.enable [
      {
        name = "tinted-shell";
        path = cfg.themes.shell.repo;
        url = "https://github.com/tinted-theming/tinted-shell";
        themes-dir = "scripts";
        supported-systems = [
          "base16"
          "base24"
        ];
      }
    ]);
  itemsForCfg = builtins.map (v: {
    inherit (v) name;
    path = v.url;
    inherit (v) themes-dir;
    inherit (v) supported-systems;
  }) items;
  cfgFile = genCfgFile {
    shell = "${cfg.shell} -c '{}'";
    default-scheme = cfg.scheme;
    items = itemsForCfg;
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
    ) items;
  };
  themesType = lib.types.submodule {
    options = {
      shell = {
        enable = lib.mkEnableOption "Enable tinty for Shell";
        repo = lib.mkOption {
          type = lib.types.path;
          default = pkgs.fetchFromGitHub {
            owner = "tinted-theming";
            repo = "tinted-shell";
            rev = "60c80f53cd3d97c25eb0580e40f0b9de84dac55f";
            hash = "sha256-eyZKShUpeIAoxhVsHAm2eqYvMp5e15NtbVrjMWFqtF8=";
          };
        };
      };
      alacritty = {
        enable = lib.mkEnableOption "Enable tinty for Alacritty";
        repo = lib.mkOption {
          type = lib.types.path;
          default = pkgs.fetchFromGitHub {
            owner = "tinted-theming";
            repo = "tinted-alacritty";
            rev = "97cd85d428adb491c6f6cf8b96663b1b4fd98561";
            hash = "sha256-Z2z7bFOBPauNEMFEA/5F6kdahTTypMt9JFTQ7yZkY6Y=";
          };
        };
      };
    };
  };
  tintyType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "Enable tinty for Tinted-Theming (base16 / base24)";
      settings = lib.mkOption {
        inherit (settingsFormat) type;
        default = { };
      };
      package = lib.mkPackageOption selfPkgs' "tinty" { };
      shell = lib.mkOption {
        type = lib.types.enum [
          "bash"
          "zsh"
        ];
        default = "bash";
      };
      scheme = lib.mkOption {
        type = lib.types.str;
        default =
          if config.theme.wallpaper.file != null then "${cfg.generate.system}-wallpaper" else "base16-mocha";
      };
      generate = {
        variant = lib.mkOption {
          type = lib.types.enum [
            "light"
            "dark"
          ];
          default = "light";
        };
        system = lib.mkOption {
          type = lib.types.enum [
            "base16"
            "base24"
          ];
          default = "base24";
        };
      };
      themes = lib.mkOption {
        type = themesType;
        default = { };
      };
    };
  };
  homeDir =
    pkgs.runCommand "tinty"
      {
        nativeBuildInputs = [ cfg.package ];
      }
      (
        ''
          mkdir -p $out/.local/share/tinted-theming/tinty/repos
          export HOME=$out
          export XDG_DATA_HOME=$out/.local/share
          mkdir -p $out/.config/tinted-theming/tinty
          export XDG_CONFIG_HOME=$out/.config
          export BASE16_CONFIG_PATH=$out/.config/tinted-theming/tinty
          cp ${cfgFile} $out/.config/tinted-theming/tinty/config.toml
          cp -r ${repos}/* $XDG_DATA_HOME/tinted-theming/tinty/repos
          find $XDG_DATA_HOME/tinted-theming/tinty/repos -type d -exec chmod 755 {} \;
          cp -r ${tintySchemes} $XDG_DATA_HOME/tinted-theming/tinty/repos/schemes
          ${
            if (config.theme.wallpaper.file != null) then
              ''
                tinty generate-scheme --system ${cfg.generate.system} --name 'Wallpaper' --slug 'wallpaper' --variant ${cfg.generate.variant} --save ${config.theme.wallpaper.file}
              ''
            else
              ""
          }
        ''
        + lib.strings.concatLines (
          builtins.map (v: ''tinty build $XDG_DATA_HOME/tinted-theming/tinty/repos/${v.name}'') items
        )
        + ''
          tinty apply ${cfg.scheme}
        ''
      );
  isBase24 = scheme: builtins.substring 0 6 scheme == "base24";
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
      packages = [
        (pkgs.writeShellScriptBin "tinty" ''
          XDG_CONFIG_HOME=${homeDir}/.config ${lib.getExe cfg.package} --config ${cfgFile} --data-dir ${homeDir}/.local/share/tinted-theming/tinty "$@"
        '')
      ];
    };
    programs = {
      alacritty = lib.mkIf (config.programs.alacritty.enable && cfg.themes.alacritty.enable) {
        settings = {
          general = {
            import = [
              "${homeDir}/.local/share/tinted-theming/tinty/repos/tinted-alacritty/colors-256/${cfg.scheme}.toml"
            ];
          };
        };
      };
      zsh = lib.mkIf (config.programs.zsh.enable && cfg.themes.shell.enable && cfg.shell == "zsh") {
        sessionVariables = {
          TINTED_SHELL_ENABLE_VARS = 1;
          TINTED_SHELL_ENABLE_BASE24_VARS = if (isBase24 cfg.scheme) then 1 else 0;
        };
        initExtra = ''
          source ${homeDir}/.local/share/tinted-theming/tinty/repos/tinted-shell/scripts/${cfg.scheme}.sh
        '';
      };
      bash = lib.mkIf (config.programs.bash.enable && cfg.themes.shell.enable && cfg.shell == "bash") {
        sessionVariables = {
          TINTED_SHELL_ENABLE_VARS = 1;
          TINTED_SHELL_ENABLE_BASE24_VARS = if (isBase24 cfg.scheme) then 1 else 0;
        };
        initExtra = ''
          source ${homeDir}/.local/share/tinted-theming/tinty/repos/tinted-shell/scripts/${cfg.scheme}.sh
        '';
      };
      tmux = lib.mkIf (config.programs.tmux.enable && cfg.themes.shell.enable) {
        extraConfig = ''
          set -g allow-passthrough on
        '';
      };
      git =
        lib.mkIf (config.programs.git.enable && config.programs.git.delta.enable && cfg.themes.shell.enable)
          {
            delta = {
              options = {
                syntax-theme = "ansi";
                light = cfg.generate.variant == "light";
              };
            };
          };
    };
  };
}

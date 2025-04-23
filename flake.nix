{
  description = "Oreore flake";

  inputs = {
    # keep-sorted start block=yes
    flake-checker = {
      url = "github:DeterminateSystems/flake-checker";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs = {
        nixpkgs-lib = {
          follows = "nixpkgs";
        };
      };
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs?shallow=1&ref=release-24.11";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    systems = {
      url = "github:nix-systems/default";
    };
    tinty-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    # keep-sorted end
  };

  outputs =
    {
      flake-parts,
      systems,
      flake-checker,
      tinty-schemes,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        inputs,
        lib,
        flake-parts-lib,
        self,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
      in
      {
        systems = import systems;
        imports =
          [ flake-parts.flakeModules.easyOverlay ]
          ++ lib.optionals (inputs.pre-commit-hooks ? flakeModule) [ inputs.pre-commit-hooks.flakeModule ]
          ++ lib.optionals (inputs.treefmt-nix ? flakeModule) [ inputs.treefmt-nix.flakeModule ];

        flake = {
          homeManagerModules = {
            theme = importApply ./home-manager/modules/theme {
              tintySchemes = tinty-schemes;
              inherit importApply;
            };
          };
        };
        perSystem =
          {
            system,
            pkgs,
            config,
            ...
          }:
          let
            treefmtBuild = config.treefmt.build;
            spkgs = import inputs.nixpkgs-stable {
              inherit system;
              config = {
                allowUnfree = true;
              };
            };
          in
          {
            _module = {
              args = {
                pkgs = import inputs.nixpkgs {
                  inherit system;
                  config = {
                    allowUnfree = true;
                  };
                };
              };
            };
            checks = config.packages;
            packages =
              import ./packages/all { inherit pkgs lib; }
              // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux (import ./packages/linux { inherit pkgs lib; });
            overlayAttrs = self.packages."${system}";
            devShells = {
              default = spkgs.mkShell {
                PFPATH = "${
                  spkgs.buildEnv {
                    name = "zsh-comp";
                    paths = config.devShells.default.nativeBuildInputs;
                    pathsToLink = [ "/share/zsh" ];
                  }
                }/share/zsh/site-functions";
                packages = with pkgs; [
                  nil
                  efm-langserver
                  nvfetcher
                ];
                inputsFrom =
                  lib.optionals (inputs.pre-commit-hooks ? flakeModule) [ config.pre-commit.devShell ]
                  ++ lib.optionals (inputs.treefmt-nix ? flakeModule) [ treefmtBuild.devShell ];
              };
            };
          }
          // lib.optionalAttrs (inputs.pre-commit-hooks ? flakeModule) {
            pre-commit = {
              check = {
                enable = true;
              };
              settings = {
                src = ./.;
                hooks = {
                  # keep-sorted start block=yes
                  flake-checker = lib.optionalAttrs (inputs.flake-checker ? packages) {
                    enable = true;
                    package = flake-checker.packages.${system}.flake-checker;
                  };
                  treefmt = {
                    enable = true;
                    packageOverrides = {
                      treefmt = treefmtBuild.wrapper;
                    };
                  };
                  # keep-sorted end
                };
              };
            };
          }
          // lib.optionalAttrs (inputs.treefmt-nix ? flakeModule) {
            formatter = treefmtBuild.wrapper;
            treefmt = {
              projectRootFile = "flake.nix";
              flakeCheck = false;
              programs = {
                # keep-sorted start block=yes
                deadnix = {
                  enable = true;
                };
                keep-sorted = {
                  enable = true;
                };
                nixfmt = {
                  enable = true;
                };
                shfmt = {
                  enable = true;
                };
                statix = {
                  enable = true;
                };
                taplo = {
                  enable = true;
                };
                # keep-sorted end
              };
            };
          };
      }
    );
}

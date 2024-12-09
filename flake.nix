{
  description = "Oreore flake";

  inputs = {
    # keep-sorted start block=yes
    flake-compat = {
      url = "github:edolstra/flake-compat";
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
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs-unstable";
        };
        nixpkgs-stable = {
          follows = "nixpkgs";
        };
        flake-compat = {
          follows = "flake-compat";
        };
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs-unstable";
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
      rust-overlay,
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
              localFlake = self;
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
          in
          {
            _module = {
              args = {
                pkgs = import inputs.nixpkgs-unstable {
                  inherit system;
                  overlays = [ rust-overlay.overlays.default ];
                };
              };
            };
            checks = config.packages;
            packages =
              import ./packages/all { inherit pkgs lib; }
              // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux (import ./packages/linux { inherit pkgs lib; });
            overlayAttrs = self.packages."${system}";
            devShells = {
              default = pkgs.mkShell {
                packages = with pkgs; [
                  nil
                  efm-langserver
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
                  deadnix = {
                    enable = true;
                  };
                  flake-checker = {
                    enable = false;
                  };
                  statix = {
                    enable = true;
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
                keep-sorted = {
                  enable = true;
                };
                nixfmt = {
                  enable = true;
                  package = pkgs.nixfmt-rfc-style;
                };
                shfmt = {
                  enable = true;
                };
                # keep-sorted end
              };
            };
          };
      }
    );
}

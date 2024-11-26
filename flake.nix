{
  description = "Oreore flake";

  inputs = {
    # keep-sorted start block=yes
    cachix = {
      url = "github:cachix/cachix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
        git-hooks = {
          follows = "pre-commit-hooks";
        };
        flake-compat = {
          follows = "flake-compat";
        };
        devenv = {
          follows = "devenv";
        };
      };
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
        cachix = {
          follows = "cachix";
        };
        nix = {
          follows = "nix";
        };
        flake-compat = {
          follows = "flake-compat";
        };
      };
    };
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
    nix = {
      url = "github:domenkozar/nix/devenv-2.24";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
        flake-parts = {
          follows = "flake-parts";
        };
        flake-compat = {
          follows = "flake-compat";
        };
        pre-commit-hooks = {
          follows = "pre-commit-hooks";
        };
      };
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
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
      self,
      flake-parts,
      systems,
      rust-overlay,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        inputs,
        lib,
        withSystem,
        flake-parts-lib,
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
          ++ lib.optionals (inputs.treefmt-nix ? flakeModule) [ inputs.treefmt-nix.flakeModule ]
          ++ lib.optionals (inputs.devenv ? flakeModule) [ inputs.devenv.flakeModule ];

        flake =
          withSystem "x86_64-linux" (
            {
              pkgs,
              system,
              config,
              ...
            }:
            {
              _module = {
                args = {
                  pkgs = import inputs.nixpkgs-unstable {
                    inherit system;
                    overlays = [ rust-overlay.overlays.default ];
                  };
                };
              };
              packages = {
                "${system}" =
                  (import ./packages/linux { inherit pkgs lib; }) // (import ./packages/all { inherit pkgs lib; });
              };
              checks = {
                "${system}" = config.packages;
              };
            }
          )
          // withSystem "aarch64-darwin" (
            {
              pkgs,
              system,
              config,
              ...
            }:
            {
              _module = {
                args = {
                  pkgs = import inputs.nixpkgs-unstable {
                    inherit system;
                    overlays = [ rust-overlay.overlays.default ];
                  };
                };
              };
              packages = {
                "${system}" = import ./packages/all { inherit pkgs lib; };
              };
              checks = {
                "${system}" = config.packages;
              };
            }
          )
          // ({
            homeManagerModules = {
              theme = importApply ./home-manager/modules/theme {
                inherit withSystem;
                localFlake = self;
              };
            };
          });
        perSystem =
          {
            system,
            pkgs,
            config,
            ...
          }:
          {
            _module = {
              args = {
                pkgs = import inputs.nixpkgs-unstable {
                  inherit system;
                  overlays = [ rust-overlay.overlays.default ];
                };
              };
            };
            overlayAttrs = config.packages;
            devShells = {
              default = pkgs.mkShell {
                packages = with pkgs; [
                  nil
                  nixfmt-rfc-style
                  efm-langserver
                ];
                inputsFrom =
                  [ ]
                  ++ lib.optionals (inputs.pre-commit-hooks ? flakeModule) [ config.pre-commit.devShell ];
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
                  treefmt = {
                    enable = true;
                    packageOverrides.treefmt = config.treefmt.build.wrapper;
                  };
                };
              };
            };
          }
          // lib.optionalAttrs (inputs.treefmt-nix ? flakeModule) {
            formatter = config.treefmt.build.wrapper;
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

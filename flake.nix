{
  description = "Oreore flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs = {
        nixpkgs-lib = {
          follows = "nixpkgs";
        };
      };
    };
    dagger = {
      url = "github:dagger/nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
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
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
        nixpkgs-stable = {
          follows = "nixpkgs";
        };
      };
    };
  };

  outputs =
    {
      self,
      pre-commit-hooks,
      treefmt-nix,
      flake-parts,
      dagger,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      imports = [ flake-parts.flakeModules.easyOverlay ];
      perSystem =
        { system, pkgs, ... }:
        let
          hooks = pre-commit-hooks.lib.${system};
          treefmtEval = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
        in
        {
          imports = [ ./packages ];
          formatter = (treefmtEval.config.build.wrapper);
          checks = {
            pre-commit-check = hooks.run {
              src = ./.;
              hooks = {
                treefmt = {
                  packageOverrides.treefmt = (treefmtEval.config.build.wrapper);
                  enable = true;
                };
              };
            };
          };
          devShells = {
            default = pkgs.mkShell {
              packages =
                (with pkgs; [
                  nil
                  nixfmt-rfc-style
                  efm-langserver
                ])
                ++ [ dagger.packages.${system}.dagger ];
              inherit (self.checks.${system}.pre-commit-check) shellHook;
              buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            };
          };
        };
    };
}

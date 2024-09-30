{
  description = "Oreore flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      pre-commit-hooks,
      nixpkgs,
      treefmt-nix,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [ "x86_64-linux" ];
        imports = [
          flake-parts.flakeModules.easyOverlay
          ./packages
        ];
      }
    )
    // (flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        { system, pkgs, ... }:
        let
          hooks = pre-commit-hooks.lib.${system};
          treefmtEval = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
        in
        {
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
              packages = with pkgs; [
                nixd
                nixfmt-rfc-style
                efm-langserver
              ];
              inherit (self.checks.${system}.pre-commit-check) shellHook;
              buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            };
          };
        };

    });
}

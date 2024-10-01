{
  pkgs,
  ghcBuild ? "ghc98",
  ...
}:
let
  haskellPackages = pkgs.haskell.packages."${ghcBuild}";
  pkg = haskellPackages.developPackage {
    root = ./.;
    modifier =
      drv:
      pkgs.haskell.lib.compose.overrideCabal (old: { platforms = [ "x86_64-linux" ]; }) (
        pkgs.haskell.lib.addBuildTools drv (with haskellPackages; [ cabal-install ])
      );
  };
in
pkg

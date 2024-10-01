{
  pkgs,
  ghcBuild ? "ghc98",
  ...
}:
let
  haskellPackages = pkgs.haskell.packages."${ghcBuild}";
  pkg = haskellPackages.developPackage {
    root = ./.;
    modifier = drv: pkgs.haskell.lib.addBuildTools drv (with haskellPackages; [ cabal-install ]);
  };
in
pkg

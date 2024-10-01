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
      pkgs.haskell.lib.compose.overrideCabal
        (pkgs.haskell.lib.addBuildTools drv (with haskellPackages; [ cabal-install ]))
        {
          meta = {
            platforms = [ "x86_64-linux" ];
          };
        };
  };
in
pkg

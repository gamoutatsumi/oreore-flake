{ pkgs, lib, ... }:
let
  xmonadpropreadEnv = pkgs.haskellPackages.ghcWithPackages (self: [
    self.xmonad-contrib
    self.X11
  ]);
in
pkgs.stdenv.mkDerivation {
  pname = "xmonadpropread";

  inherit (pkgs.haskellPackages.xmonad-contrib) src version;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    ${lib.getExe' xmonadpropreadEnv "ghc"} -o $out/bin/xmonadpropread \
      --make scripts/xmonadpropread.hs
    runHook postInstall
  '';

  meta = {
    platforms = lib.platforms.linux;
    mainProgram = "xmonadpropread";
    homepage = "https://github.com/xmonad/xmonad-contrib";
  };
}

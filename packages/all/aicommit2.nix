{ pkgs, lib, ... }:
let
  nodejs = pkgs.nodejs_20;
  pnpm = pkgs.pnpm_9;
  version = "2.1.4";
  src = pkgs.fetchFromGitHub {
    owner = "tak-bro";
    repo = "aicommit2";
    rev = "v${version}";
    hash = "sha256-r8H+b/oC4Et/7LvO3jiLOZ2eLBhCAFZbkJW+0TA41yE=";
    leaveDotGit = true;
  };
  pname = "aicommit2";
in
pkgs.stdenv.mkDerivation {
  inherit version pname src;
  buildInputs = [ nodejs ];
  nativeBuildInputs = [
    pnpm.configHook
    pkgs.makeWrapper
  ];
  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-NQQmk3ZYpHUCgqc89BmBEJKbh/c/Lvv+yz+Gqa+in30=";
  };
  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib,bin}
    cp -r {node_modules,dist} $out/lib

    makeWrapper $out/lib/dist/cli.mjs $out/bin/aicommit2

    runHook postInstall
  '';
  meta = {
    license = lib.licenses.mit;
    platforms = nodejs.meta.platforms;
  };
}

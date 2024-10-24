{ pkgs, mySource, ... }:
let
  nodejs = pkgs.nodejs_18;
  pnpm = pkgs.pnpm_8;
in
pkgs.stdenv.mkDerivation rec {
  inherit (mySource) pname version src;
  buildInputs = [ nodejs ];
  nativeBuildInputs = [
    pnpm.configHook
    pkgs.makeWrapper
  ];
  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-DiEmhDXdjDHTkOq5iISQLEYohFcAmJ7hXGDO+cY4PhI=";
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
}

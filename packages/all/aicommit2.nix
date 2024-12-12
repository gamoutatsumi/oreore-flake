{
  # keep-sorted start
  lib,
  pkgs,
  sources,
  # keep-sorted end
  ...
}:
let
  nodejs = pkgs.nodejs_20;
  pnpm = pkgs.pnpm_9;
in
pkgs.stdenv.mkDerivation {
  inherit (sources.aicommit2) version pname src;
  buildInputs = [ nodejs ];
  nativeBuildInputs = [
    pnpm.configHook
    pkgs.makeWrapper
  ];
  pnpmDeps = pnpm.fetchDeps {
    inherit (sources.aicommit2) version pname src;
    hash = "sha256-kWe4oCIEFQJkzsQrRqd/B/XORkYY49WAaaaAaOXYFGk=";
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
  checkPhase = ''
    pnpm test
  '';
  meta = {
    license = lib.licenses.mit;
    inherit (nodejs.meta) platforms;
  };
}

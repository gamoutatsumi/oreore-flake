{
  # keep-sorted start
  lib,
  pkgs,
  sources,
  # keep-sorted end
  ...
}:
pkgs.buildNpmPackage {
  inherit (sources.mcp-hub) version pname src;
  npmDepsHash = "sha256-A4d9l8YpRaJdNfa934IEG0a2SLRmwW+CfTWgoXx3vwA=";
  meta = {
    license = lib.licenses.mit;
    inherit (pkgs.nodejs.meta) platforms;
  };
}

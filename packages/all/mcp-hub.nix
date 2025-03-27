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
  npmDepsHash = "sha256-hC5QxKxHAtV94DwT5m0zR+VAA8Jn4SuB36fdAhVT73g=";
  meta = {
    license = lib.licenses.mit;
    inherit (pkgs.nodejs.meta) platforms;
  };
}

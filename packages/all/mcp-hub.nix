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
  npmDepsHash = "sha256-LvxbZa+2pcz3G9nWECSbL0P20/5pn+RnHIIPvSOs6W0=";
  meta = {
    license = lib.licenses.mit;
    inherit (pkgs.nodejs.meta) platforms;
  };
}

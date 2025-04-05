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
  npmDepsHash = "sha256-viBafGv3nLpF1O9rBmboGzn/NyYqNVvmWIVMZAM1pAA=";
  meta = {
    license = lib.licenses.mit;
    inherit (pkgs.nodejs.meta) platforms;
  };
}

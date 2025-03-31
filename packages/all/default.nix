{ pkgs, lib, ... }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
lib.genAttrs [
  "mcp-hub"
] (name: pkgs.callPackage ./${name}.nix { inherit sources; })

{ pkgs, lib, ... }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
lib.genAttrs [
  "aicommit2"
  "tinty"
] (name: pkgs.callPackage ./${name}.nix { inherit sources; })

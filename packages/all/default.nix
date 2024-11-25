{ pkgs, lib, ... }:
lib.genAttrs [
  "aicommit2"
  "tinty"
] (name: pkgs.callPackage ./${name}.nix { })

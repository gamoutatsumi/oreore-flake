{ pkgs, lib, ... }: lib.genAttrs [ "aicommit2" ] (name: pkgs.callPackage ./${name}.nix { })

{ pkgs, lib, ... }:
lib.genAttrs [
  "changeBrightness"
  "toggleMicMute"
  "maimFull"
  "maimSelect"
  "playerctlStatus"
  "getPulseVolume"
  "changeVolume"
  "launchPolybar"
  "rofiSystem"
  "xmonadpropread"
] (name: pkgs.callPackage ./${name}.nix { })

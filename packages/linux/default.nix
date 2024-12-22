{ pkgs, lib, ... }:
lib.genAttrs [
  # keep-sorted start
  "changeBrightness"
  "changeVolume"
  "getPulseVolume"
  "launchPolybar"
  "maimFull"
  "maimSelect"
  "mfcj7100cdw-cups"
  "playerctlStatus"
  "rofiSystem"
  "toggleMicMute"
  "xmonadpropread"
  # keep-sorted end
] (name: pkgs.callPackage ./${name}.nix { })

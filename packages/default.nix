{ pkgs, ... }:
{
  overlayAttrs = {
    changeBrightness = pkgs.callPackage ./changeBrightness.nix { };
    toggleMicMute = pkgs.callPackage ./toggleMicMute.nix { };
    maimFull = pkgs.callPackage ./maimFull.nix { };
    maimSelect = pkgs.callPackage ./maimSelect.nix { };
    playerctlStatus = pkgs.callPackage ./playerctlStatus.nix { };
    getPulseVolume = pkgs.callPackage ./getPulseVolume.nix { };
    changeVolume = pkgs.callPackage ./changeVolume.nix { };
    launchPolybar = pkgs.callPackage ./launchPolybar.nix { };
    rofiSystem = pkgs.callPackage ./rofiSystem.nix { };
    xmonadpropread = pkgs.callPackage ./xmonadpropread.nix { };
    aicommit2 = pkgs.callPackage ./aicommit2.nix { };
  };
}

{ lib, pkgs, ... }:
pkgs.writeShellApplication {
  name = "maimSelect";
  runtimeInputs = [
    pkgs.maim
    pkgs.clip
    pkgs.coreutils-full
  ];
  derivationArgs = {
    platforms = [ "x86_64-linux" ];
  };
  text = ''
    FILENAME="''${HOME}/Pictures/screenshot-''$(date +%Y-%m-%d-%T).png"

    maim -s -u "''${FILENAME}" 

    xclip -selection c -t image/png "''${FILENAME}"
  '';
}

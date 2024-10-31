{ pkgs, lib, ... }:
pkgs.writeShellApplication {
  name = "maimSelect";
  runtimeInputs = [
    pkgs.maim
    pkgs.xclip
    pkgs.coreutils-full
  ];
  derivationArgs = {
    meta = {
      platforms = lib.platforms.linux;
    };
  };
  text = ''
    FILENAME="''${HOME}/Pictures/screenshot-''$(date +%Y-%m-%d-%T).png"

    maim -s -u "''${FILENAME}" 

    xclip -selection c -t image/png "''${FILENAME}"
  '';
}
